package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestExamplesTargetGroups(t *testing.T) {

	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/target_groups",
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)
}