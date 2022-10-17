local kap = import 'lib/kapitan.libjsonnet';
local inv = kap.inventory();
local params = inv.parameters.secrets;
local argocd = import 'lib/argocd.libjsonnet';

local app = argocd.App('secrets', params.namespace);

{
  secrets: app,
}
