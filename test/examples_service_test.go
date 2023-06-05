package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestExamplesService(t *testing.T) {

	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/service",
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)
}