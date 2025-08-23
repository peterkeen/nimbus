task :apply_crds => "talos:setup" do
  filepath = File.join(Dir.pwd, "bootstrap/crds/helmfile.yaml")
  sh %Q{helmfile --file "#{filepath}" template --include-crds --no-hooks --quiet | yq ea --exit-status 'select(.kind == "CustomResourceDefinition")' - > /tmp/rendered_crds.yaml}
  sh "kubectl apply --server-side --filename /tmp/rendered_crds.yaml" 
end

task :apply_namespaces => "talos:setup" do
  Dir.glob(File.join(Dir.pwd, "kubernetes/apps/*")) do |dir|
    if Dir.exist?(dir) 
      namespace = File.basename(dir)
      next if namespace.start_with?('.') 
      sh "kubectl create namespace #{namespace} --dry-run=client --output=yaml | kubectl apply --server-side -f -"
    end
  end
end

task :apply_resources => :apply_namespaces do
  filepath = File.join(Dir.pwd, "bootstrap/resources.yaml")
  sh "op inject --in-file #{filepath} | kubectl apply --server-side -f -"
end

task :apply => [:apply_crds, :apply_resources] do
  path = File.join(Dir.pwd, "bootstrap/helmfile.yaml")
  sh "helmfile --file #{path} sync"
end

