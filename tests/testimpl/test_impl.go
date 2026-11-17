package testimpl

import (
	"context"
	"os"
	"strings"
	"testing"

	"github.com/Azure/azure-sdk-for-go/sdk/azcore/arm"
	"github.com/Azure/azure-sdk-for-go/sdk/azidentity"
	"github.com/Azure/azure-sdk-for-go/sdk/resourcemanager/keyvault/armkeyvault"
	monitor "github.com/Azure/azure-sdk-for-go/sdk/resourcemanager/monitor/armmonitor"
	"github.com/Azure/azure-sdk-for-go/sdk/resourcemanager/operationalinsights/armoperationalinsights"
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
	expectedQuery               = `AzureDiagnostics
| where Category == "AuditEvent"
| where OperationName has "Secret"
| where ResultType != "Success"
| summarize FailureCount = count() by bin(TimeGenerated, 5m)`
)

// Per-example values from each example's test.tfvars, keyed by example directory.
var expectedAlertNames = map[string]string{
	"public_vault":  "launch-vault-eus-sandbox-000-sqa-001-kv_secret_operation_failures",
	"private_vault": "launch-vault-eus-sandbox-000-sqa-000-kv_secret_operation_failures",
}

var expectedDailyQuotaGb = map[string]float64{
	"public_vault":  -1,
	"private_vault": 1,
}

var expectedCustomProperties = map[string]string{
	"alertType": "scheduled-query",
	"service":   "key-vault",
}

var expectedPublicNetworkAccess = map[string]string{
	"public_vault":  "Enabled",
	"private_vault": "Disabled",
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

	t.Run("TestKeyVaultSettings", func(t *testing.T) {
		checkKeyVaultSettings(t, ctx, subscriptionId, cred)
	})

	t.Run("TestScheduledQueryAlert", func(t *testing.T) {
		checkScheduledQueryAlert(t, ctx, subscriptionId, cred)
	})

	t.Run("TestLogAnalyticsWorkspace", func(t *testing.T) {
		checkLogAnalyticsWorkspace(t, ctx, subscriptionId, cred)
	})
}

// expectedForExample looks up the current example's value, failing the test when the example has none.
func expectedForExample[V any](t *testing.T, ctx types.TestContext, values map[string]V) V {
	value, ok := values[ctx.CurrentTestName()]
	require.True(t, ok, "no expected value for example %q", ctx.CurrentTestName())
	return value
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

func checkKeyVaultSettings(t *testing.T, ctx types.TestContext, subscriptionId string, cred *azidentity.DefaultAzureCredential) {
	resourceGroupName := terraform.Output(t, ctx.TerratestTerraformOptions(), "resource_group_name")
	keyVaultName := terraform.Output(t, ctx.TerratestTerraformOptions(), "key_vault_name")

	vault, err := getKeyVaultClient(t, subscriptionId, cred).Get(context.TODO(), resourceGroupName, keyVaultName, nil)
	require.NoError(t, err, "failed to get key vault")
	properties := vault.Properties
	require.NotNil(t, properties)

	// Both examples set enable_rbac_authorization = true and purge_protection_enabled = false.
	require.NotNil(t, properties.EnableRbacAuthorization)
	assert.Equal(t, true, *properties.EnableRbacAuthorization)

	purgeProtection := false
	if properties.EnablePurgeProtection != nil {
		purgeProtection = *properties.EnablePurgeProtection
	}
	assert.Equal(t, false, purgeProtection)

	expectedAccess := expectedForExample(t, ctx, expectedPublicNetworkAccess)
	require.NotNil(t, properties.PublicNetworkAccess)
	assert.Equal(t, expectedAccess, *properties.PublicNetworkAccess)

	// The module creates a private endpoint only when public network access is disabled.
	privateEndpointID := terraform.Output(t, ctx.TerratestTerraformOptions(), "private_endpoint_id")
	if expectedAccess == "Enabled" {
		assert.Equal(t, "", privateEndpointID)
		assert.Len(t, properties.PrivateEndpointConnections, 0)
		return
	}
	require.Len(t, properties.PrivateEndpointConnections, 1)
	connection := properties.PrivateEndpointConnections[0].Properties
	require.NotNil(t, connection)
	require.NotNil(t, connection.PrivateEndpoint)
	assert.Equal(t, strings.ToLower(privateEndpointID), strings.ToLower(*connection.PrivateEndpoint.ID))
	require.NotNil(t, connection.PrivateLinkServiceConnectionState)
	assert.Equal(t, armkeyvault.PrivateEndpointServiceConnectionStatusApproved, *connection.PrivateLinkServiceConnectionState.Status)
}

func checkLogAnalyticsWorkspace(t *testing.T, ctx types.TestContext, subscriptionId string, cred *azidentity.DefaultAzureCredential) {
	workspaceID := terraform.Output(t, ctx.TerratestTerraformOptions(), "log_analytics_workspace_id")
	parsed, err := arm.ParseResourceID(workspaceID)
	require.NoError(t, err, "log_analytics_workspace_id is not a resource ID")

	client, err := armoperationalinsights.NewWorkspacesClient(subscriptionId, cred, nil)
	require.NoError(t, err, "Error creating Log Analytics workspaces client")

	workspace, err := client.Get(context.Background(), parsed.ResourceGroupName, parsed.Name, nil)
	require.NoError(t, err, "Error getting Log Analytics workspace")
	require.NotNil(t, workspace.Properties)
	require.NotNil(t, workspace.Properties.WorkspaceCapping)
	require.NotNil(t, workspace.Properties.WorkspaceCapping.DailyQuotaGb)
	assert.Equal(t, expectedForExample(t, ctx, expectedDailyQuotaGb), *workspace.Properties.WorkspaceCapping.DailyQuotaGb)
}

func checkScheduledQueryAlert(t *testing.T, ctx types.TestContext, subscriptionId string, cred *azidentity.DefaultAzureCredential) {
	options := ctx.TerratestTerraformOptions()
	alertIDs := terraform.OutputMap(t, options, "scheduled_query_alert_ids")
	alertNames := terraform.OutputMap(t, options, "scheduled_query_alert_names")
	resourceGroupName := terraform.Output(t, options, "resource_group_name")

	require.Contains(t, alertNames, expectedAlertKey)
	alertName := alertNames[expectedAlertKey]
	assert.Equal(t, expectedForExample(t, ctx, expectedAlertNames), alertName)

	client, err := monitor.NewScheduledQueryRulesClient(subscriptionId, cred, nil)
	require.NoError(t, err, "Error creating scheduled query rules client")

	rule, err := client.Get(context.Background(), resourceGroupName, alertName, nil)
	require.NoError(t, err, "Error getting scheduled query alert")
	assert.Equal(t, strings.ToLower(alertIDs[expectedAlertKey]), strings.ToLower(*rule.ID))
	assert.Equal(t, monitor.KindLogAlert, *rule.Kind)

	properties := rule.Properties
	require.NotNil(t, properties)

	// With no scope_id on the alert, the module scopes it to the Key Vault.
	keyVaultID := terraform.Output(t, options, "key_vault_id")
	require.Len(t, properties.Scopes, 1)
	assert.Equal(t, strings.ToLower(keyVaultID), strings.ToLower(*properties.Scopes[0]))

	assert.Equal(t, monitor.AlertSeverityTwo, *properties.Severity)
	assert.Equal(t, expectedEvaluationFrequency, *properties.EvaluationFrequency)
	assert.Equal(t, expectedWindowDuration, *properties.WindowSize)
	assert.Equal(t, true, *properties.Enabled)
	assert.Equal(t, true, *properties.SkipQueryValidation)

	require.NotNil(t, properties.Criteria)
	require.Len(t, properties.Criteria.AllOf, 1)
	condition := properties.Criteria.AllOf[0]
	assert.Equal(t, expectedQuery, strings.TrimSpace(*condition.Query))
	assert.Equal(t, monitor.ConditionOperatorGreaterThan, *condition.Operator)
	assert.Equal(t, monitor.TimeAggregationCount, *condition.TimeAggregation)
	assert.Equal(t, expectedThreshold, *condition.Threshold)

	// The example's action_group is the only one wired to the alert.
	actionGroupID := terraform.Output(t, options, "action_group_id")
	require.NotNil(t, properties.Actions)
	require.Len(t, properties.Actions.ActionGroups, 1)
	assert.Equal(t, strings.ToLower(actionGroupID), strings.ToLower(*properties.Actions.ActionGroups[0]))

	// email_subject reaches the API as an action property, not a first class field.
	require.Contains(t, properties.Actions.ActionProperties, "Email.Subject")
	assert.Equal(t, expectedEmailSubject, *properties.Actions.ActionProperties["Email.Subject"])

	actualCustomProperties := make(map[string]string, len(properties.Actions.CustomProperties))
	for key, value := range properties.Actions.CustomProperties {
		actualCustomProperties[key] = *value
	}
	assert.Equal(t, expectedCustomProperties, actualCustomProperties)

	// The examples pass their own resource_name in tags, which overrides the alert's.
	require.Contains(t, rule.Tags, "provisioner")
	assert.Equal(t, "terraform", *rule.Tags["provisioner"])
	require.Contains(t, rule.Tags, "Purpose")
	assert.Equal(t, "Terraform Examples", *rule.Tags["Purpose"])
}

func getKeyVaultClient(t *testing.T, subscriptionId string, cred *azidentity.DefaultAzureCredential) *armkeyvault.VaultsClient {
	client, err := armkeyvault.NewVaultsClient(subscriptionId, cred, nil)
	if err != nil {
		t.Fatalf("Error creating Key Vault client: %v", err)
	}
	return client
}
