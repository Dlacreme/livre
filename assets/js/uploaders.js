let Uploaders = {}

Uploaders.S3 = function (entries, onViewError) {
  entries.forEach(entry => {
    console.log(entry);
    let xhr = new XMLHttpRequest()
    onViewError(() => xhr.abort())
    xhr.onload = () => xhr.status === 200 ? entry.progress(100) : entry.error()
    xhr.onerror = () => entry.error()

    xhr.upload.addEventListener("progress", (event) => {
      if (event.lengthComputable) {
        let percent = Math.round((event.loaded / event.total) * 100)
        if (percent < 100) { entry.progress(percent) }
      }
    })

    let url = entry.meta.url
    xhr.open("PUT", url, true)
    xhr.send(entry.file)

    const urlObj = new URL(url);
    urlObj.search = '';
    const clientUrl = urlObj.toString();
    const targetInput = document.querySelector(`input[name="${entry.meta.target}"]`)
    const targetPreview = document.getElementById(`preview-${entry.meta.target}`)

    if (targetInput) {
      targetInput.value = clientUrl;
    }
    if (targetInput) {
      //     targetPreview.src = clientUrl;
    }
  })
}

export default Uploaders;