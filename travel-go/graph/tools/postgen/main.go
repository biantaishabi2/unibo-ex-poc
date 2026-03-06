package main

import (
	"fmt"
	"os"
	"path/filepath"
	"regexp"
	"strings"
)

var entImportPattern = regexp.MustCompile(`"([^"]+/ent)"`)

var nodeEntityTypes = []string{
	"HotelOffer",
	"FlightOffer",
	"VacationOffer",
	"TrainOffer",
	"TravelOrder",
	"TravelFulfillment",
}

func main() {
	targetPath := resolveResolverFile()
	raw, err := os.ReadFile(targetPath)
	if err != nil && !os.IsNotExist(err) {
		fatalf("读取 %s 失败: %v", targetPath, err)
	}

	matches := entImportPattern.FindSubmatch(raw)
	entImport := ""
	if len(matches) >= 2 {
		entImport = string(matches[1])
	} else {
		fallbackRaw, err := os.ReadFile("resolver.go")
		if err != nil {
			fatalf("无法从 %s 提取 ent import，且读取 resolver.go 失败: %v", targetPath, err)
		}
		fallbackMatch := entImportPattern.FindSubmatch(fallbackRaw)
		if len(fallbackMatch) < 2 {
			fatalf("无法从 %s 与 resolver.go 提取 ent import 路径", targetPath)
		}
		entImport = string(fallbackMatch[1])
	}

	patched := fmt.Sprintf(`package graph

import (
	"context"

	"%s"
)

// Node is the resolver for the node field.
func (r *queryResolver) Node(ctx context.Context, id string) (ent.Noder, error) {
	return GetLoaders(ctx, r.Client).NodeByID.Load(ctx, id)
}

// Nodes is the resolver for the nodes field.
func (r *queryResolver) Nodes(ctx context.Context, ids []string) ([]ent.Noder, error) {
	return GetLoaders(ctx, r.Client).NodeByID.LoadAll(ctx, ids)
}

// Query returns QueryResolver implementation.
func (r *Resolver) Query() QueryResolver { return &queryResolver{r} }

type queryResolver struct{ *Resolver }
`, entImport)

	if err := os.WriteFile(targetPath, []byte(patched), 0o644); err != nil {
		fatalf("写入 %s 失败: %v", targetPath, err)
	}
	if err := writeEntityIDResolvers(entImport); err != nil {
		fatalf("写入 entity_id.resolvers.go 失败: %v", err)
	}
}

func writeEntityIDResolvers(entImport string) error {
	if len(nodeEntityTypes) == 0 {
		return nil
	}
	var b strings.Builder
	b.WriteString("package graph\n\n")
	b.WriteString("import (\n")
	b.WriteString("\t\"context\"\n")
	b.WriteString("\t\"fmt\"\n\n")
	b.WriteString(fmt.Sprintf("\t\"%s\"\n", entImport))
	b.WriteString(")\n\n")
	for _, typeName := range nodeEntityTypes {
		structName := resolverStructName(typeName)
		b.WriteString(fmt.Sprintf("// %s returns %sResolver implementation.\n", typeName, typeName))
		b.WriteString(fmt.Sprintf("func (r *Resolver) %s() %sResolver { return &%s{r} }\n\n", typeName, typeName, structName))
		b.WriteString(fmt.Sprintf("type %s struct{ *Resolver }\n\n", structName))
		b.WriteString(fmt.Sprintf("// ID is the resolver for the id field.\nfunc (r *%s) ID(ctx context.Context, obj *ent.%s) (string, error) {\n\treturn fmt.Sprintf(\"%s:%%v\", obj.ID), nil\n}\n\n", structName, typeName, typeName))
	}
	return os.WriteFile("entity_id.resolvers.go", []byte(b.String()), 0o644)
}

func resolverStructName(typeName string) string {
	if typeName == "" {
		return "entityIDResolver"
	}
	if len(typeName) == 1 {
		return strings.ToLower(typeName) + "IDResolver"
	}
	return strings.ToLower(typeName[:1]) + typeName[1:] + "IDResolver"
}

func resolveResolverFile() string {
	matches, err := filepath.Glob("*.resolvers.go")
	if err != nil {
		fatalf("扫描 resolver 文件失败: %v", err)
	}
	for _, candidate := range matches {
		raw, err := os.ReadFile(candidate)
		if err != nil {
			continue
		}
		text := string(raw)
		if strings.Contains(text, "type queryResolver struct") || strings.Contains(text, "func (r *queryResolver) Node") {
			return candidate
		}
	}
	return "ent.resolvers.go"
}

func fatalf(format string, args ...interface{}) {
	fmt.Fprintf(os.Stderr, "[unibo-postgen] "+format+"\n", args...)
	os.Exit(1)
}
