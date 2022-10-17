// main template for secrets
local kap = import 'lib/kapitan.libjsonnet';
local kube = import 'lib/kube.libjsonnet';
local inv = kap.inventory();
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

// Define outputs below
{
  '10_opaque': opaqueSecrets(),
}
