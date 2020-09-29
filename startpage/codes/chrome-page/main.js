const INPUT = document.querySelector(".input")
const TITLE = document.querySelector(".title")

window.onload = () => {
  INPUT.value = ""
  INPUT.focus()
}

// enums
const cmd = {
  SEARCH: /^:s\s/, // default to google
  OPEN: /^:o\s/,
  FACEBOOK: /^:fb/,
  GITHUB: /^:gh/,
  GMAIL: /^:gm/,
  YOUTUBE: /^:yt/,
  WA: /^:wa/,
  ANKI: /^:an/
}

document.addEventListener("keydown", e => {
  if (e.key === ":") {
    INPUT.focus()
    INPUT.value = ""
  }

  if (e.key === "Escape") {
    INPUT.value = ""
    INPUT.blur()
  }
})

INPUT.addEventListener("keydown", e => {
  const {
    key,
    target: { value }
  } = e

  if (key === "Enter") {
    if (value.match(cmd.SEARCH)) {
      window.location.href = `https://www.google.com/search?q=${value.replace(
        cmd.SEARCH,
        ""
      )}`
    }

    if (value.match(cmd.OPEN))
      window.location.href = `https://${value.replace(cmd.OPEN, "")}`

    if (value.match(cmd.FACEBOOK)) window.location.href = "https://facebook.com"
    if (value.match(cmd.GITHUB)) window.location.href = "https://github.com"
    if (value.match(cmd.GMAIL)) window.location.href = "https://mail.google.com"
    if (value.match(cmd.YOUTUBE)) window.location.href = "https://youtube.com"
    if (value.match(cmd.WA)) window.location.href = "https://web.whatsapp.com"
    if (value.match(cmd.ANKI)) window.location.href = "https://ankiweb.net"
  }
})
