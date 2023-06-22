// main template for secrets
local kap = import 'lib/kapitan.libjsonnet';
local kube = import 'lib/kube.libjsonnet';
local inv = kap.inventory();
local com = import 'lib/commodore.libjsonnet';

// The hiera parameters for the component
local params = inv.parameters.secrets;

local namespacedName(name, namespace='') = {
  local namespaced = std.splitLimit(name, '/', 1),
  local ns = if namespace != '' then namespace else params.namespace,
  namespace: if std.length(namespaced) > 1 then namespaced[0] else ns,
  name: if std.length(namespaced) > 1 then namespaced[1] else namespaced[0],
};

local opaqueSecrets() = [
  local values = std.get(params.opaque, name);
  {
    apiVersion: 'v1',
    kind: 'Secret',
    metadata: {
      name: namespacedName(name, '').name,
      namespace: namespacedName(name, '').namespace,
    },
    type: 'Opaque',
    stringData: {
      [key]: values[key]
      for key in std.objectFields(values)
    },
  }
  for name in std.objectFields(params.opaque)
];

local legacy =
  if std.objectHas(params, 'opaque') then
    local transformed = {
      [name]: {
        metadata: {
          name: namespacedName(name, '').name,
          namespace: namespacedName(name, '').namespace,
        },
        type: 'Opaque',
        stringData: params.opaque[name],
      }
      for name in std.objectFields(params.opaque)
    };
    std.trace('Parameter `opaque` is deprecated. Please migrate to parameter `secrets`.', transformed)
  else
    {};

local secrets = legacy + params.secrets;
{
  '10_secrets': std.prune(com.generateResources(secrets, kube.Secret)),
}
