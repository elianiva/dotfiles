const INPUT = document.querySelector(".container__search")

window.onload = () => {
  INPUT.value = ""
  INPUT.focus()
}

// enums
const cmd = {
  SEARCH: /^:s\s/,
  OPEN: /^:o\s/,
  FACEBOOK: /^:fb/,
  GITHUB: /^:gh/,
  GMAIL: /^:gm/,
  YOUTUBE: /^:yt/,
  WA: /^:wa/,
  ANKI: /^:an/,
  TWITTER: /^:tw/,
  TRELLO: /^:tr/,
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
    target: { value },
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

const JP = document.querySelector(".word__jp")
const KANA = document.querySelector(".word__kana")
const EN = document.querySelector(".word__en")
const WORD = document.querySelector(".word__text")
const INFO = document.querySelector(".word__info")
WORD.style.opacity = 0

const setFromLocalStorage = () => {
  // try to set from `localStorage` first
  const result = JSON.parse(localStorage.getItem("result"))
  JP.textContent = result.kanji
  KANA.textContent = result.kana
  EN.textContent = result.en

  INFO.href = `https://jisho.org/search/${result.kanji}`
  WORD.style.opacity = 1
}

setFromLocalStorage()

document.addEventListener("DOMContentLoaded", async () => {
  try {
    const res = await fetch(
      "https://random-jp-api.vercel.app/api/rand?level=n4"
    )
    const { data: result } = await res.json()
    localStorage.setItem("result", JSON.stringify(result))

    JP.textContent = result.kanji
    KANA.textContent = result.kana
    EN.textContent = result.en

    INFO.href = `https://jisho.org/search/${result.kanji}`
  } catch (err) {
    setFromLocalStorage()
    console.error(err)
  }
})
