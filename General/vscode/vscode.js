document.addEventListener('DOMContentLoaded', function() {
    const checkElement = setInterval(() => {
        const commandDialog = document.querySelector(".quick-input-widget");
        if (commandDialog) {
            if (commandDialog.style.display !== "none") {
                runMyScript();
            }

            const observer = new MutationObserver((mutations) => {
                mutations.forEach((mutation) => {
                    if (mutation.type === 'attributes' && mutation.attributeName === 'style') {
                        if (commandDialog.style.display === 'none') {
                            handleEscape();
                        } else {
                            runMyScript();
                        }
                    }
                });
            });

            observer.observe(commandDialog, { attributes: true });
            clearInterval(checkElement);
        } else {
            console.log("Command dialog not found yet. Retrying...");
        }
    }, 500);

    document.addEventListener('keydown', function(event) {
        if ((event.metaKey || event.ctrlKey) && event.key === 'p') {
            event.preventDefault();
            runMyScript();
        } else if (event.key === 'Escape' || event.key === 'Esc') {
            event.preventDefault();
            handleEscape();
        }
    });

    function runMyScript() {
        const targetDiv = document.querySelector(".monaco-workbench");
        if (!targetDiv) {
            console.error("Target div not found");
            return;
        }

        const existingElement = document.getElementById("command-blur");
        if (existingElement) {
            existingElement.remove();
        }

        const newElement = document.createElement("div");
        newElement.setAttribute('id', 'command-blur');
        newElement.style.position = 'absolute';
        newElement.style.width = '100%';
        newElement.style.height = '100%';
        newElement.style.background = 'rgba(0, 0, 0, .15)';
        newElement.style.top = '0';
        newElement.style.left = '0';
        newElement.style.backdropFilter = 'blur(8px)';
        newElement.style.zIndex = '10'; // Add this to make sure it's not overlapping with the command palette

        newElement.addEventListener('click', function() {
            newElement.remove();
        });

        targetDiv.appendChild(newElement);
    }

    function handleEscape() {
        const element = document.getElementById("command-blur");
        if (element) {
            element.remove();
        }
    }
});

