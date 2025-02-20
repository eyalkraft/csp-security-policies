package bundle

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestCISKubernetes(t *testing.T) {
	assert := assert.New(t)
	policies, err := CISKubernetes()

	assert.NoError(err)
	assert.Greater(len(policies), 70)
}

func TestCISEKS(t *testing.T) {
	assert := assert.New(t)
	policies, err := CISEks()

	assert.NoError(err)
	assert.NotEmpty(policies)
}
