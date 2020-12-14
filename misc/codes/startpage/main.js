const INPUT = document.querySelector(".category__input")
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
  ANKI: /^:an/,
  TWITTER: /^:tw/,
  TRELLO: /^:tr/
}

window.addEventListener("keydown", e => {
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
    if (value.toLowerCase().match(cmd.SEARCH)) {
      window.location.href = `https://www.google.com/search?q=${value.replace(
        cmd.SEARCH,
        ""
      )}`
    }

    if (value.toLowerCase().match(cmd.OPEN))
      window.location.href = `https://${value.replace(cmd.OPEN, "")}`

    if (value.toLowerCase().match(cmd.FACEBOOK))
      window.location.href = "https://facebook.com"
    if (value.toLowerCase().match(cmd.GITHUB))
      window.location.href = "https://github.com"
    if (value.toLowerCase().match(cmd.GMAIL))
      window.location.href = "https://mail.google.com"
    if (value.toLowerCase().match(cmd.YOUTUBE))
      window.location.href = "https://youtube.com"
    if (value.toLowerCase().match(cmd.WA))
      window.location.href = "https://web.whatsapp.com"
    if (value.toLowerCase().match(cmd.ANKI))
      window.location.href = "https://ankiweb.net"
    if (value.toLowerCase().match(cmd.TRELLO))
      window.location.href = "https://trello.com"
    if (value.toLowerCase().match(cmd.TWITTER))
      window.location.href = "https://twitter.com"
  }
})

const getGreet = () => {
  const date = new Date()
  const time = date.getHours()

  if (time >= 0 && time <= 10) return "< おはよう />"
  if (time > 10 && time <= 18) return "< こんにちは />"
  if (time > 18 && time <= 21) return "< こんばんは />"
  if (time > 21 && time <= 24) return "< おやすみなさい />"
}

TITLE.innerHTML = getGreet()
