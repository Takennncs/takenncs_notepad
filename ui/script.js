let quill;
let isLocked = false;
let currentNoteId = null;
let lastSavedTime = null;

document.body.classList.remove('visible');

window.addEventListener('load', function() {
    initializeQuill();
    setupEventListeners();
    setupNUICallbacks();
});

function initializeQuill() {
    quill = new Quill('#editor', {
        modules: {
            toolbar: { container: '#toolbar' },
            clipboard: { matchVisual: false }
        },
        placeholder: 'Kirjuta siia oma märkmed...',
        theme: 'snow'
    });
}

function setupEventListeners() {
    document.getElementById('closeBtn')?.addEventListener('click', closeDocument);
    document.getElementById('cancelBtn')?.addEventListener('click', closeDocument);
    document.getElementById('saveBtn')?.addEventListener('click', saveDocument);
    document.getElementById('lockBtn')?.addEventListener('click', toggleLock);
    document.getElementById('duplicateBtn')?.addEventListener('click', duplicateDocument);

    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape') closeDocument();
        if (e.ctrlKey && e.key === 's') { e.preventDefault(); saveDocument(); }
    });
}

function setupNUICallbacks() {
    window.addEventListener('message', function(event) {
        const data = event.data;
        switch(data.action) {
            case 'open':
                openEditor(data.data);
                break;
            case 'close':
                closeDocument();
                break;
            case 'updateContent':
                updateContent(data.data);
                break;
        }
    });
}

function openEditor(data) {
    currentNoteId = data.noteId || null;
    isLocked = data.locked || false;

    const lockBtn = document.getElementById('lockBtn');
    const container = document.querySelector('.note-container');
    
    if (isLocked) {
        lockBtn.innerHTML = '<i class="fas fa-lock"></i>';
        lockBtn.classList.add('locked');
        container.classList.add('locked');
    } else {
        lockBtn.innerHTML = '<i class="fas fa-lock-open"></i>';
        lockBtn.classList.remove('locked');
        container.classList.remove('locked');
    }

    document.getElementById('noteTitle').value = data.title || '';

    if (data.content && data.content !== '') {
        try {
            quill.setContents(typeof data.content === 'object' ? data.content : JSON.parse(data.content));
        } catch { quill.setText(data.content); }
    } else {
        quill.setText('');
    }

    if (data.lastEdited) {
        lastSavedTime = data.lastEdited;
        updateLastSavedTime();
    }

    document.body.classList.add('visible');
    document.getElementById('noteContainer').style.display = 'flex';
}

function saveDocument() {
    const title = document.getElementById('noteTitle').value || 'Pealkirjata märkmik';
    const content = JSON.stringify(quill.getContents());

    fetch(`https://${GetParentResourceName()}/saveDocument`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
            title: title,
            content: content,
            locked: isLocked,
            noteId: currentNoteId,
            lastEdited: Date.now()
        })
    })
    .then(resp => resp.json())
    .then(resp => { if (resp.ok) { lastSavedTime = Date.now(); updateLastSavedTime(); } });
}

function duplicateDocument() {
    const title = document.getElementById('noteTitle').value || 'Pealkirjata märkmik';
    const content = JSON.stringify(quill.getContents());

    fetch(`https://${GetParentResourceName()}/duplicateDocument`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
            title: title,
            content: content,
            locked: false,
            noteId: currentNoteId,
            lastEdited: Date.now()
        })
    });
}

function closeDocument() {
    document.body.classList.remove('visible');
    fetch(`https://${GetParentResourceName()}/close`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    });
}

function toggleLock() {
    if (isLocked) return;
    isLocked = !isLocked;
    const lockBtn = document.getElementById('lockBtn');
    const container = document.querySelector('.note-container');
    
    if (isLocked) {
        lockBtn.innerHTML = '<i class="fas fa-lock"></i>';
        lockBtn.classList.add('locked');
        container.classList.add('locked');
    } else {
        lockBtn.innerHTML = '<i class="fas fa-lock-open"></i>';
        lockBtn.classList.remove('locked');
        container.classList.remove('locked');
    }
}

function updateLastSavedTime() {
    if (lastSavedTime) {
        const date = new Date(lastSavedTime);
        document.getElementById('lastSaved').textContent = `Viimati salvestatud: ${date.toLocaleTimeString('et-EE', { hour: '2-digit', minute: '2-digit' })}`;
    }
}

function updateContent(data) {
    if (data.title) document.getElementById('noteTitle').value = data.title;
    if (data.content) {
        try { quill.setContents(JSON.parse(data.content)); }
        catch { quill.setText(data.content); }
    }
    if (data.locked !== undefined) isLocked = data.locked;
    if (data.lastEdited) { lastSavedTime = data.lastEdited; updateLastSavedTime(); }

    const lockBtn = document.getElementById('lockBtn');
    const container = document.querySelector('.note-container');

    if (isLocked) {
        lockBtn.innerHTML = '<i class="fas fa-lock"></i>';
        lockBtn.classList.add('locked');
        container.classList.add('locked');
    } else {
        lockBtn.innerHTML = '<i class="fas fa-lock-open"></i>';
        lockBtn.classList.remove('locked');
        container.classList.remove('locked');
    }
}

function GetParentResourceName() { return 'takenncs_notepad'; }