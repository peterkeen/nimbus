require "tmpdir"

task :apply_crds => "talos:setup" do
  filepath = File.join(Dir.pwd, "bootstrap/crds/helmfile.yaml")
  sh %Q{helmfile --file "#{filepath}" template --include-crds --no-hooks --quiet | yq ea --exit-status 'select(.kind == "CustomResourceDefinition")' - > /tmp/rendered_crds.yaml}
  sh "kubectl apply --server-side --filename /tmp/rendered_crds.yaml"  rescue nil
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

task :apply_git_secret => :apply_namespaces do
  Dir.mktmpdir do |dir|
    sh "op read 'op://fmycvdzmeyvbndk7s7pjyrebtq/lx4kcymgkkukpwes5vxhsczjcm/private key' > #{dir}/identity"
    sh "op read 'op://fmycvdzmeyvbndk7s7pjyrebtq/lx4kcymgkkukpwes5vxhsczjcm/known_hosts' > #{dir}/known_hosts"

    sh "kubectl create -n flux-system secret generic infra-git-ssh-identity --type=string --from-file=identity=#{dir}/identity --from-file=known_hosts=#{dir}/known_hosts"
  end
end

task :apply => [:apply_crds, :apply_git_secret, :apply_resources] do
  path = File.join(Dir.pwd, "bootstrap/helmfile.yaml.gotmpl")
  values_path = File.join(Dir.pwd, "bootstrap/values.env")
  sh "op run --env-file=#{values_path} -- helmfile --file #{path} sync"
end

