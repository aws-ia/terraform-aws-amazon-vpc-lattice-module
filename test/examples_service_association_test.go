package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestExamplesServiceAssociation(t *testing.T) {

	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/service_association",
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)
}