import 'https://cdn.skypack.dev/@hotwired/turbo-rails'
import 'https://cdn.skypack.dev/alpine-turbo-drive-adapter'
import Alpine from 'https://cdn.skypack.dev/alpinejs'
window.Alpine = Alpine
Alpine.start()

const endMarker = '[Deployed Rails] End'
const outputContainerEl = document.getElementById('deploy-output')
const spinnerEl = document.getElementById('spinner')

window.pipeLogs = () => {
  spinnerEl.classList.remove('hidden')
  window.logEventSource = new EventSource(`/deployed/log_output`)

  window.logEventSource.onmessage = (event) => {
    if (!Alpine.store('process').running) {
      window.logEventSource.close()
    } else {
      if (event.data.includes("[Deployed] End")) {
        window.stopPipeLogs()
      } else {
        outputContainerEl.innerHTML += event.data
      }
    }

    outputContainerEl.scrollIntoView({ behavior: "smooth", block: "end" })
    spinnerEl.scrollIntoView({ behavior: "smooth", block: "end" })
  }
}

window.stopPipeLogs = () => {
  if (typeof(window.logEventSource) !== 'undefined') {
    window.logEventSource.close()
  }
  spinnerEl.classList.add('hidden')
  Alpine.store('process').stop()
}

window.execDeployed = (commandToRun) => {
  Alpine.store('process').start()

  let endpoint = `/deployed/execute`

  // Create a data object with your payload (in this case, a command)
  const data = { command: commandToRun }

  // Define the fetch options for the POST request
  const options = {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(data)
  }

  // Perform the POST request using the fetch API
  fetch(endpoint, options)
    .then(response => {
      if (response.ok) {
        outputContainerEl.innerHTML += "<div class='py-2'></div>"
        outputContainerEl.innerHTML += `<div class='text-slate-400'>[Deployed] Command Received: kamal ${commandToRun}</div>`
        window.pipeLogs()
        return response.json(); // Parse the JSON response if needed
      } else {
        throw new Error('Network response was not ok');
      }
    })
    .catch(error => {
      console.error('Fetch error:', error)
    })
}

window.abortDeployed = () => {
  // Let the frontend know we're starting
  Alpine.store('process').startAbort()

  let outputContainerEl = document.getElementById('deploy-output')
  let spinnerEl = document.getElementById('spinner')

  outputContainerEl.innerHTML += `<div class="text-red-400">Aborting...</div>`

  let endpoint = `/deployed/cancel`

  const options = {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' }
  }

  // Perform the POST request using the fetch API
  fetch(endpoint, options)
    .then(response => {
      if (response.ok) {
        window.stopPipeLogs()
        Alpine.store('process').stop()
        Alpine.store('process').resetAbort()
        return response.json(); // Parse the JSON response if needed
      } else {
        throw new Error('Network response was not ok');
      }
    })
    .then(data => {
      console.log(data)
      outputContainerEl.innerHTML += `<div class="text-yellow-400">Aborted process with PID ${data.message}</div>`
    })
    .catch(error => {
      console.error('Fetch error:', error)
    })
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
