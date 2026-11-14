# Local inert documentation export; run after compilation with the app/Jason ebin paths.
alias PublicSituationMachineTurnZero.Workshop.{AlongsideStaging,GeometryExploration}
initial=AlongsideStaging.new()
{:ok,a,_,_}=AlongsideStaging.command(initial,{:pivot,30})
{:ok,a,_,_}=AlongsideStaging.command(a,:appoint_wedging)
{:ok,staged,_,_}=AlongsideStaging.command(a,:stage)
{:ok,a,_,_}=AlongsideStaging.command(staged,:retain_furnishing)
{:ok,a,_,_}=AlongsideStaging.command(a,{:pivot,60})
{:ok,a,_,_}=AlongsideStaging.command(a,:appoint_wedging)
{:ok,a,_,_}=AlongsideStaging.command(a,:stage)
{:ok,angular,_,_}=AlongsideStaging.command(a,:retain_furnishing)
File.write!(Path.join(__DIR__,"staging-witness.json"),Jason.encode!(%{geometry_contract: GeometryExploration.version(),scope: :staging_geometry_preview,initial: AlongsideStaging.model(initial),staged: AlongsideStaging.model(staged),angular: AlongsideStaging.model(angular)},pretty: true))
