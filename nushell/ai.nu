def ai [instruction] {
  if ($instruction | is-empty) {
    return
  }

  let key = (pass show elianiva/openrouter | str trim)

  let body = {
    model: "deepseek/deepseek-chat-v3-0324:free",
    messages: [
      { role: "system", content: "You are a helpful assistant that turns natural language into Nushell commands on Linux. You can only provide command with no explanations, no quotation, just plain string." }
      { role: "user", content: $instruction }
    ]
  }

  print "Asking AI for command suggestion..."
  let response = (http post https://openrouter.ai/api/v1/chat/completions
    --content-type "application/json"
    --headers [Authorization $"Bearer ($key)" ]
    $body)

  let ai_command = $response.choices.0.message.content

  # trim newline cuz that's dangerous as fuck
  let sanitized = $ai_command | str trim

  commandline edit --insert $sanitized
}
