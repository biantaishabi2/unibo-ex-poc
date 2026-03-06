package graph

import (
	"context"
	"fmt"
	"io"
	"strconv"
	"time"

	"github.com/99designs/gqlgen/graphql"
	"github.com/google/uuid"
	"github.com/vektah/gqlparser/v2/ast"
)

// scalar Time

func (ec *executionContext) unmarshalInputTime(_ context.Context, v any) (time.Time, error) {
	switch v := v.(type) {
	case string:
		return time.Parse(time.RFC3339Nano, v)
	case time.Time:
		return v, nil
	default:
		return time.Time{}, fmt.Errorf("time must be a string, got %T", v)
	}
}

func (ec *executionContext) _Time(ctx context.Context, sel ast.SelectionSet, v *time.Time) graphql.Marshaler {
	if v == nil {
		return graphql.Null
	}
	return graphql.WriterFunc(func(w io.Writer) {
		io.WriteString(w, strconv.Quote(v.Format(time.RFC3339Nano)))
	})
}

// scalar UUID

func (ec *executionContext) unmarshalInputUUID(_ context.Context, v any) (uuid.UUID, error) {
	switch v := v.(type) {
	case string:
		return uuid.Parse(v)
	case uuid.UUID:
		return v, nil
	default:
		return uuid.UUID{}, fmt.Errorf("uuid must be a string, got %T", v)
	}
}

func (ec *executionContext) _UUID(ctx context.Context, sel ast.SelectionSet, v *uuid.UUID) graphql.Marshaler {
	if v == nil {
		return graphql.Null
	}
	return graphql.WriterFunc(func(w io.Writer) {
		io.WriteString(w, strconv.Quote(v.String()))
	})
}
