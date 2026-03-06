package main

import (
	"crypto/sha256"
	"encoding/json"
	"fmt"
	"io"
	"os"
	"path/filepath"
)

// DriftManifest 漂移检测清单
type DriftManifest struct {
	Generator string            `json:"generator"`
	Files     map[string]string `json:"files"`
}

func main() {
	manifestPath := "drift_manifest.json"
	if len(os.Args) > 1 {
		manifestPath = os.Args[1]
	}

	data, err := os.ReadFile(manifestPath)
	if err != nil {
		fmt.Fprintf(os.Stderr, "error: cannot read manifest: %v\n", err)
		os.Exit(1)
	}

	var manifest DriftManifest
	if err := json.Unmarshal(data, &manifest); err != nil {
		fmt.Fprintf(os.Stderr, "error: cannot parse manifest: %v\n", err)
		os.Exit(1)
	}

	baseDir := filepath.Dir(manifestPath)
	drifted := 0

	for filePath, expectedHash := range manifest.Files {
		fullPath := filepath.Join(baseDir, filePath)
		f, err := os.Open(fullPath)
		if err != nil {
			fmt.Printf("MISSING  %s\n", filePath)
			drifted++
			continue
		}

		h := sha256.New()
		if _, err := io.Copy(h, f); err != nil {
			f.Close()
			fmt.Printf("ERROR    %s: %v\n", filePath, err)
			drifted++
			continue
		}
		f.Close()

		actualHash := fmt.Sprintf("%x", h.Sum(nil))
		if actualHash != expectedHash {
			fmt.Printf("DRIFTED  %s\n", filePath)
			fmt.Printf("  expected: %s\n", expectedHash)
			fmt.Printf("  actual:   %s\n", actualHash)
			drifted++
		}
	}

	if drifted > 0 {
		fmt.Printf("\n%d file(s) drifted from generated state.\n", drifted)
		os.Exit(1)
	}

	fmt.Printf("OK: all %d files match the generated manifest.\n", len(manifest.Files))
}
