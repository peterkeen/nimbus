task :setup do
  @TALOS_DIR = File.join(Dir.pwd, "talos")

  in_talos_dir do
    validate_tool("op")
    validate_tool("talhelper")

    FileUtils.mkdir_p("clusterconfig")

    sh "op document get --vault fmycvdzmeyvbndk7s7pjyrebtq 53dgrve5ahxxehmt5q3u5jirpm > clusterconfig/talsecret.yaml"
    sh "talhelper genconfig --secret-file clusterconfig/talsecret.yaml --no-gitignore"
    sh "talosctl config add dummy"
    sh "talosctl config add nimbus"
    sh "talosctl config use-context dummy"
    sh "talosctl config remove nimbus -y"
    sh "talosctl config merge clusterconfig/talosconfig"
    sh "talosctl config use-context nimbus"
    sh "talosctl kubeconfig clusterconfig/kubeconfig"
  end
end

task :apply => :setup do
  cmd = %w[apply]
  if ENV["reboot"] == "true"
    cmd << '--extra-flags="--mode=reboot"'
  end

  talhelper_cmd(cmd.join(" "))
end

task :preview => :setup do
  cmd = %w[apply --extra-flags="--dry-run"]
  talhelper_cmd(cmd.join(" "))
end

task :upgrade => :setup do
  talhelper_cmd("upgrade")
end  

task :dashboard => :setup do
  in_talos_dir do
    exec "talosctl dashboard"
  end
end

task :genapply => :setup do
  in_talos_dir do
    exec "talhelper gencommand apply"
  end
end
