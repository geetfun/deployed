import 'https://cdn.skypack.dev/@hotwired/turbo-rails'
import 'https://cdn.skypack.dev/alpine-turbo-drive-adapter'
import Alpine from 'https://cdn.skypack.dev/alpinejs'
window.Alpine = Alpine
Alpine.start()

window.execKamal = (commandToRun) => {
  // Let the frontend know we're starting
  Alpine.store('process').start()

  let outputContainerEl = document.getElementById('deploy-output')
  let spinnerEl = document.getElementById('spinner')

  if (outputContainerEl.innerHTML !== '') {
    outputContainerEl.innerHTML += "<div class='py-2'></div>"
  }

  spinnerEl.classList.remove('hidden')
  var source = new EventSource(`/kamal/execute?command=${commandToRun}`)

  source.onmessage = (event) => {
    if (!Alpine.store('process').running) {
      source.close()
    } else {
      if (event.data.includes('[Kamal Rails] End transmission')) {
        source.close()
        outputContainerEl.innerHTML += `<div class="text-slate-400 pb-4">Executed: <span class='text-slate-400 font-semibold'>kamal ${commandToRun}</span></div>`
        spinnerEl.classList.add('hidden')

        // Let the frontend know we're done
        Alpine.store('process').stop()
      } else {
        outputContainerEl.innerHTML += event.data
      }
    }

    outputContainerEl.scrollIntoView({ behavior: "smooth", block: "end" })
    spinnerEl.scrollIntoView({ behavior: "smooth", block: "end" })
  }
}

window.abortKamal = () => {
  // Let the frontend know we're starting
  Alpine.store('process').startAbort()

  let outputContainerEl = document.getElementById('deploy-output')
  let spinnerEl = document.getElementById('spinner')

  outputContainerEl.innerHTML += `<div class="text-red-400 py-4">Aborting...</div>`

  var source = new EventSource(`/kamal/cancel`)

  source.onmessage = (event) => {
    if (event.data.includes('[Kamal Rails] End transmission')) {
      source.close()

      spinnerEl.classList.add('hidden')

      // Let the frontend know we're done
      Alpine.store('process').stop()
      Alpine.store('process').resetAbort()
    } else {
      outputContainerEl.innerHTML += event.data
    }

    outputContainerEl.scrollIntoView({ behavior: "smooth", block: "end" })
    spinnerEl.scrollIntoView({ behavior: "smooth", block: "end" })
  }
}

// Some other JS that probably should be refactored at some point...
document.addEventListener('DOMContentLoaded', (event) => {
  // Hackish way to refresh git status with turbo frames
  // setInterval(() => {
  //   document.getElementById('git-status').reload()
  // }, 2500)

  // Resizing functionality
  let isResizing = false
  let initialY
  let initialHeight

  const deployOutputContainer = document.getElementById('deploy-output-container')
  const resizeHandle = document.getElementById('resize-handle')

  const startResize = (e) => {
    isResizing = true
    initialY = e.clientY
    initialHeight = deployOutputContainer.clientHeight
  }

  const stopResize = () => { isResizing = false }

  const resize = (e) => {
    if (isResizing) {
      const deltaY = initialY - e.clientY
      deployOutputContainer.style.height = initialHeight + deltaY + 'px'
    }
  }

  resizeHandle.addEventListener('mousedown', startResize)
  document.addEventListener('mousemove', resize)
  document.addEventListener('mouseup', stopResize)
})
