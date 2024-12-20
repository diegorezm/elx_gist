// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

import hjs from 'highlight.js'
// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")

// this is only for file extensions
// where fileExt !== language name.
// there is no need to add, for exemple, java here since the file extension
// and the language name are the same. 

function updateLineNumbers(value) {
  const lineNumberText = document.querySelector(".line-numbers")
  if (!lineNumberText) return;

  const lines = value.split("\n")
  const numbers = lines.map((_, i) => i + 1).join("\n") + "\n"
  lineNumberText.value = numbers
}

let Hooks = {
  SearchRedirect: {
    mounted() {
      this.el.addEventListener("keydown", (e) => {
        if (e.key === "Enter") {
          const searchQuery = e.target.value
          const url = `/gists/all?search=${encodeURIComponent(searchQuery)}`
          window.location.href = url
        }
      })

    }
  },
  ToggleEdit: {
    mounted() {
      this.el.addEventListener("click", () => {
        const editForm = document.getElementById("edit-section")
        const hjsSection = document.getElementById("hjs-section")
        if (!editForm || !hjsSection) return
        const isHidden = editForm.classList.contains("hidden")
        if (isHidden) {
          editForm.classList.remove("hidden")
          editForm.classList.add("block")
          hjsSection.classList.add("hidden")
        } else {
          editForm.classList.remove("block")
          editForm.classList.add("hidden")
          hjsSection.classList.remove("hidden")
        }
      })
    }
  },
  CopyToClipBoard: {
    mounted() {
      this.el.addEventListener("click", (e) => {
        const textToCopy = this.el.getAttribute("data-clipboard-gist")
        if (textToCopy) {
          navigator.clipboard.writeText(textToCopy).then(() => {
            console.log("Gist copied to clipboard!")
          }).catch(e => {
            console.error(e)
          })
        }
      })
    }
  },
  Highlight: {
    mounted() {
      let name = this.el.getAttribute("data-name")
      if (!name) return

      let codeblock = this.el.querySelector("pre code")
      if (!codeblock) return

      const codewrapper = this.el.querySelector("code")
      const fileExt = name.split(".").pop()
      const codeClassName = this.getSyntaxType(fileExt)
      codewrapper.classList.add(codeClassName)
      hjs.highlightElement(codeblock)

      updateLineNumbers(codeblock.textContent)
    },
    getSyntaxType(fileExt) {
      let codeClassName;
      const extToLanguage = {
        "heex": "html",
        "py": "python",
        "js": "javascript",
        "ts": "typescript",
        "ex": "elixir",
        "go": "golang",
        "rs": "rust",
      }

      if (fileExt in extToLanguage) {
        codeClassName = `language-${extToLanguage[fileExt]}`
      } else {
        codeClassName = `language-${fileExt}`
      }
      return codeClassName
    },
    trimCodeBlock(codeblock) {
      const lines = codeblock.textContent.split("\n")
      if (lines.length > 2) {
        lines.shift()
        lines.pop()
      }
      codeblock.textContent = lines.join("\n")
      return codeblock
    }
  },
  UpdateLineNumbers: {
    mounted() {
      const lineNumberText = document.querySelector("#gist-line-numbers")

      this.el.addEventListener("input", () => {
        updateLineNumbers(this.el.value)
      })

      this.el.addEventListener("scroll", () => {
        lineNumberText.scrollTop = this.el.scrollTop
      })

      this.el.addEventListener("keydown", (e) => {
        if (e.key == "Tab") {
          e.preventDefault()
          let start = this.el.selectionStart
          let end = this.el.selectionEnd
          this.el.value = this.el.value.substring(0, start) + "\t" + this.el.value.substring(end)
          this.el.selectionStart = this.el.selectionEnd = start + 1
        }
      })

      this.handleEvent("clear-textareas", () => {
        console.log("this is the event")
        this.el.value = ""
        lineNumberText.value = "1\n"
      })

      updateLineNumbers(this.el.value)
    },
  }
}

let liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: {_csrf_token: csrfToken},
  hooks: Hooks
})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket
