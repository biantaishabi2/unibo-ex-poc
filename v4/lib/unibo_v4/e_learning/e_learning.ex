defmodule UniboV4.ELearning do
  use Ash.Domain

  resources do
    resource UniboV4.ELearning.Course
    resource UniboV4.ELearning.Slide
    resource UniboV4.ELearning.Enrollment
    resource UniboV4.ELearning.SlideProgress
    resource UniboV4.ELearning.User
  end
end
