package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestExamplesVPCAssociation(t *testing.T) {

	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/vpc_associations",
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)
}