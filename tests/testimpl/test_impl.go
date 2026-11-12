package testimpl

import (
	"context"
	"fmt"
	"os"
	"strings"
	"testing"

	"github.com/Azure/azure-sdk-for-go/sdk/azidentity"
	"github.com/Azure/azure-sdk-for-go/sdk/resourcemanager/keyvault/armkeyvault"
	monitor "github.com/Azure/azure-sdk-for-go/sdk/resourcemanager/monitor/armmonitor"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/launchbynttdata/lcaf-component-terratest/types"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// Expected values mirror the alert configured in each example's test.tfvars.
const (
	expectedAlertKey            = "kv_secret_operation_failures"
	expectedEvaluationFrequency = "PT5M"
	expectedWindowDuration      = "PT30M"
	expectedEmailSubject        = "Key Vault secret operation failures detected"
	expectedThreshold           = float64(0)
)

var expectedCustomProperties = map[string]string{
	"alertType": "scheduled-query",
	"service":   "key-vault",
}

func TestComposableKeyVault(t *testing.T, ctx types.TestContext) {
	subscriptionId := os.Getenv("ARM_SUBSCRIPTION_ID")
	if len(subscriptionId) == 0 {
		t.Fatal("ARM_SUBSCRIPTION_ID environment variable is not set")
	}

	cred, err := azidentity.NewDefaultAzureCredential(nil)
	if err != nil {
		t.Fatalf("Unable to get credentials: %v\n", err)
	}

	t.Run("TestKeyVaultID", func(t *testing.T) {
		checkKeyVaultID(t, ctx, subscriptionId, cred)
	})

	t.Run("TestScheduledQueryAlert", func(t *testing.T) {
		checkScheduledQueryAlert(t, ctx, subscriptionId, cred)
	})
}

func checkKeyVaultID(t *testing.T, ctx types.TestContext, subscriptionId string, cred *azidentity.DefaultAzureCredential) {
	resourceGroupName := terraform.Output(t, ctx.TerratestTerraformOptions(), "resource_group_name")
	keyVaultID := terraform.Output(t, ctx.TerratestTerraformOptions(), "key_vault_id")
	keyVaultName := terraform.Output(t, ctx.TerratestTerraformOptions(), "key_vault_name")

	client := getKeyVaultClient(t, subscriptionId, cred)

	vault, err := client.Get(context.TODO(), resourceGroupName, keyVaultName, nil)
	if err != nil {
		t.Fatalf("failed to get key vault: %v", err)
	}

	actualKeyVaultID := *vault.ID

	assert.Equal(t, keyVaultID, actualKeyVaultID, "Key Vault ID does not match")
}

func checkScheduledQueryAlert(t *testing.T, ctx types.TestContext, subscriptionId string, cred *azidentity.DefaultAzureCredential) {
	options := ctx.TerratestTerraformOptions()
	alertIDs := terraform.OutputMap(t, options, "scheduled_query_alert_ids")
	alertNames := terraform.OutputMap(t, options, "scheduled_query_alert_names")
	resourceGroupName := terraform.Output(t, options, "resource_group_name")

	require.Contains(t, alertNames, expectedAlertKey)
	alertName := alertNames[expectedAlertKey]

	client, err := monitor.NewScheduledQueryRulesClient(subscriptionId, cred, nil)
	require.NoError(t, err, "Error creating scheduled query rules client")

	rule, err := client.Get(context.Background(), resourceGroupName, alertName, nil)
	require.NoError(t, err, "Error getting scheduled query alert")
	assert.Equal(t, strings.ToLower(alertIDs[expectedAlertKey]), strings.ToLower(*rule.ID))
	assert.Equal(t, monitor.KindLogAlert, *rule.Kind)

	properties := rule.Properties
	require.NotNil(t, properties)

	// With no scope_id on the alert, the module falls back to the workspace it creates.
	workspacePrefix := strings.ToLower(fmt.Sprintf(
		"/subscriptions/%s/resourceGroups/%s/providers/Microsoft.OperationalInsights/workspaces/",
		subscriptionId, resourceGroupName,
	))
	require.Len(t, properties.Scopes, 1)
	assert.True(t, strings.HasPrefix(strings.ToLower(*properties.Scopes[0]), workspacePrefix),
		"alert scope %q should be a workspace in %s", *properties.Scopes[0], resourceGroupName)

	assert.Equal(t, monitor.AlertSeverityTwo, *properties.Severity)
	assert.Equal(t, expectedEvaluationFrequency, *properties.EvaluationFrequency)
	assert.Equal(t, expectedWindowDuration, *properties.WindowSize)
	assert.Equal(t, true, *properties.Enabled)
	assert.Equal(t, true, *properties.SkipQueryValidation)

	require.NotNil(t, properties.Criteria)
	require.Len(t, properties.Criteria.AllOf, 1)
	condition := properties.Criteria.AllOf[0]
	assert.Contains(t, *condition.Query, "MICROSOFT.KEYVAULT")
	assert.Equal(t, monitor.ConditionOperatorGreaterThan, *condition.Operator)
	assert.Equal(t, monitor.TimeAggregationCount, *condition.TimeAggregation)
	assert.Equal(t, expectedThreshold, *condition.Threshold)

	// The example's action_group is the only one wired to the alert.
	require.NotNil(t, properties.Actions)
	require.Len(t, properties.Actions.ActionGroups, 1)
	actionGroupPrefix := strings.ToLower(fmt.Sprintf(
		"/subscriptions/%s/resourceGroups/%s/providers/microsoft.insights/actionGroups/",
		subscriptionId, resourceGroupName,
	))
	assert.True(t, strings.HasPrefix(strings.ToLower(*properties.Actions.ActionGroups[0]), actionGroupPrefix),
		"alert action group %q should be in %s", *properties.Actions.ActionGroups[0], resourceGroupName)

	// email_subject reaches the API as an action property, not a first class field.
	require.Contains(t, properties.Actions.ActionProperties, "Email.Subject")
	assert.Equal(t, expectedEmailSubject, *properties.Actions.ActionProperties["Email.Subject"])

	actualCustomProperties := make(map[string]string, len(properties.Actions.CustomProperties))
	for key, value := range properties.Actions.CustomProperties {
		actualCustomProperties[key] = *value
	}
	assert.Equal(t, expectedCustomProperties, actualCustomProperties)
}

func getKeyVaultClient(t *testing.T, subscriptionId string, cred *azidentity.DefaultAzureCredential) *armkeyvault.VaultsClient {
	client, err := armkeyvault.NewVaultsClient(subscriptionId, cred, nil)
	if err != nil {
		t.Fatalf("Error creating Key Vault client: %v", err)
	}
	return client
}
