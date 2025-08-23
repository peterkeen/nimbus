task :apply_crds do
  filepath = File.join(Dir.pwd, "bootstrap/crds.yaml")
  sh %Q{helmfile --file "#{filepath}" template --include-crds --no-hooks --quiet | yq ea --exit-status 'select(.kind == "CustomResourceDefinition")' - > /tmp/rendered_crds.yaml}
  sh "kubectl apply --filename /tmp/rendered_crds.yaml" 
end

task :apply do
  path = File.join(Dir.pwd, "bootstrap/helmfile.yaml")
  sh "helmfile --file #{path} sync"
end

