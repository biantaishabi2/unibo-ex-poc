defmodule UniboExPoc.ELearning do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboExPoc.ELearning.Course
    resource UniboExPoc.ELearning.Course.Version
    resource UniboExPoc.ELearning.Slide
    resource UniboExPoc.ELearning.Slide.Version
    resource UniboExPoc.ELearning.Enrollment
    resource UniboExPoc.ELearning.Enrollment.Version
    resource UniboExPoc.ELearning.SlideProgress
    resource UniboExPoc.ELearning.SlideProgress.Version
    resource UniboExPoc.ELearning.Party
  end
end
