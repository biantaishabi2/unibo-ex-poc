package main

import (
	"context"
	"log"
	"net/http"
	"os"

	"github.com/biantaishabi2/unibo-ex-poc/travel-go/ent"
	_ "github.com/biantaishabi2/unibo-ex-poc/travel-go/ent/runtime"
	"github.com/biantaishabi2/unibo-ex-poc/travel-go/graph"
	i18nPkg "github.com/biantaishabi2/unibo-ex-poc/travel-go/i18n"
	"github.com/biantaishabi2/unibo-ex-poc/travel-go/middleware"
	workersPkg "github.com/biantaishabi2/unibo-ex-poc/travel-go/workers"

	"github.com/99designs/gqlgen/graphql/handler"
	"github.com/99designs/gqlgen/graphql/playground"
	"github.com/jackc/pgx/v5/pgxpool"
	_ "github.com/lib/pq"
	"github.com/riverqueue/river"
	"github.com/riverqueue/river/riverdriver/riverpgxv5"
)

func main() {
	databaseURL := os.Getenv("DATABASE_URL")
	if databaseURL == "" {
		databaseURL = "host=localhost port=5432 user=postgres dbname=app sslmode=disable"
	}
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	client, err := ent.Open("postgres", databaseURL)
	if err != nil {
		log.Fatalf("failed opening connection to postgres: %v", err)
	}
	defer client.Close()

	if err := client.Schema.Create(context.Background()); err != nil {
		log.Fatalf("failed creating schema resources: %v", err)
	}

	// 初始化 i18n
	i18nPkg.Init()

	jwtSecret := os.Getenv("JWT_SECRET")
	if jwtSecret == "" {
		jwtSecret = "changeme"
	}

	authPolicy := middleware.LoadEntryAuthPolicyFromEnv()

	// 中文注释：初始化 River worker runtime，并将 generated workers + periodic jobs 接入运行入口。
	riverWorkers := river.NewWorkers()
	workersPkg.RegisterWorkers(riverWorkers)
	riverConfig := &river.Config{
		Workers: riverWorkers,
		Queues: map[string]river.QueueConfig{
			"default": river.QueueConfig{MaxWorkers: 10},
		},
	}
	if err := workersPkg.RegisterPeriodicJobs(riverConfig); err != nil {
		log.Fatalf("failed registering periodic jobs: %v", err)
	}
	riverPool, err := pgxpool.New(context.Background(), databaseURL)
	if err != nil {
		log.Fatalf("failed creating pgx pool for river: %v", err)
	}
	defer riverPool.Close()
	riverClient, err := river.NewClient(riverpgxv5.New(riverPool), riverConfig)
	if err != nil {
		log.Fatalf("failed creating river client: %v", err)
	}
	if err := riverClient.Start(context.Background()); err != nil {
		log.Fatalf("failed starting river client: %v", err)
	}
	defer func() {
		if err := riverClient.Stop(context.Background()); err != nil {
			log.Printf("failed stopping river client: %v", err)
		}
	}()

	srv := handler.NewDefaultServer(graph.NewSchema(client))
	srv.AroundOperations(graph.NewDataLoaderOperationMiddleware(client))
	srv.AroundOperations(middleware.NewEntryAuthOperationMiddleware(authPolicy))
	srv.AroundFields(graph.NewFieldMiddleware())
	srv.SetErrorPresenter(middleware.GraphQLErrorPresenter)
	mux := http.NewServeMux()
	mux.Handle("/graphql", srv)
	mux.Handle("/playground", playground.Handler("GraphQL Playground", "/graphql"))

	withAuth := middleware.AuthMiddleware(jwtSecret)(i18nPkg.LocaleMiddleware(mux))

	addr := ":" + port
	log.Printf("listening on %s", addr)
	log.Printf("GraphQL playground: http://localhost:%s/playground", port)
	log.Fatal(http.ListenAndServe(addr, withAuth))
}
