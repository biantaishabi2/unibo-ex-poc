defmodule UniboV4.ELearning do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboV4.ELearning.Course
    resource UniboV4.ELearning.Course.Version
    resource UniboV4.ELearning.Slide
    resource UniboV4.ELearning.Slide.Version
    resource UniboV4.ELearning.Enrollment
    resource UniboV4.ELearning.Enrollment.Version
    resource UniboV4.ELearning.SlideProgress
    resource UniboV4.ELearning.SlideProgress.Version
    resource UniboV4.ELearning.Party
  end
end
