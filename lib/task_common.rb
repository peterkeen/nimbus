def talhelper_cmd(command)
  in_talos_dir do
    validate_tool("talhelper")
    generated = `talhelper gencommand #{command}`
    sh generated
  end
end

def validate_tool(tool)
  unless system("which #{tool}")
    raise "Tool required but not found: #{tool}"
  end
end

def in_talos_dir
  if @TALOS_DIR.nil?
    warn "Error: you forgot to depend on :setup"
    exit 1
  end

  Dir.chdir(@TALOS_DIR) do
    yield
  end
end
