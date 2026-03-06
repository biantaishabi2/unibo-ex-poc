defmodule UniboExPoc.Repo do
  use AshPostgres.Repo,
    otp_app: :travel

  # 安装 Ash 默认扩展（citext 等）
  def installed_extensions do
    ["ash-functions", "uuid-ossp", "citext"]
  end

  # 声明最低支持的 PostgreSQL 版本，避免编译期告警
  def min_pg_version do
    %Version{major: 16, minor: 0, patch: 0}
  end
end
