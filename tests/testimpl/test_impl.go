package testimpl

import (
	"context"
	"os"
	"testing"

	"github.com/Azure/azure-sdk-for-go/sdk/azidentity"
	"github.com/Azure/azure-sdk-for-go/sdk/resourcemanager/keyvault/armkeyvault"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/launchbynttdata/lcaf-component-terratest/types"
	"github.com/stretchr/testify/assert"
)

func TestKeyVaultComplete(t *testing.T, ctx types.TestContext) {
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

func getKeyVaultClient(t *testing.T, subscriptionId string, cred *azidentity.DefaultAzureCredential) *armkeyvault.VaultsClient {
	client, err := armkeyvault.NewVaultsClient(subscriptionId, cred, nil)
	if err != nil {
		t.Fatalf("Error creating Key Vault client: %v", err)
	}
	return client
}
