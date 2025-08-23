task :apply_crds do
  filepath = File.join(Dir.pwd, "bootstrap/crds.yaml")
  crds = `helmfile --file "#{filepath}" template --include-crds --no-hooks --quiet | yq ea --exit-status 'select(.kind == "CustomResourceDefinition")' -`
  puts crds
end

task :apply do
  path = File.join(Dir.pwd, "bootstrap/helmfile.yaml")
  sh "helmfile --file #{path} sync"
end

