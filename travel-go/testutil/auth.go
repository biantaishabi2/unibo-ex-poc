package testutil

import (
	"net/http"
)

// AuthenticatedRequest creates an HTTP request with a Bearer token.
func AuthenticatedRequest(method, url, token string) (*http.Request, error) {
	req, err := http.NewRequest(method, url, nil)
	if err != nil {
		return nil, err
	}
	req.Header.Set("Authorization", "Bearer "+token)
	return req, nil
}
