package worker

import (
	"fmt"

	"github.com/riverqueue/river"

)

// RegisterWorkers 将所有生成的 Worker 注册到 River。
func RegisterWorkers(workers *river.Workers) {

}

// BuildPeriodicJobs 生成 scheduled_tasks 对应的 periodic job 注册项。
func BuildPeriodicJobs() ([]*river.PeriodicJob, error) {
	periodicJobs := make([]*river.PeriodicJob, 0, 0)

	return periodicJobs, nil
}

// RegisterPeriodicJobs 将 periodic jobs 挂载到 River config。
func RegisterPeriodicJobs(config *river.Config) error {
	if config == nil {
		return fmt.Errorf("river config is nil")
	}
	periodicJobs, err := BuildPeriodicJobs()
	if err != nil {
		return err
	}
	config.PeriodicJobs = append(config.PeriodicJobs, periodicJobs...)
	return nil
}
