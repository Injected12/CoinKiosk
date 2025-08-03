let products = [];
let editingProduct = null;

// Listen for messages from Lua
window.addEventListener('message', function(event) {
    const data = event.data;
    
    switch(data.type) {
        case 'openAdmin':
            openAdmin(data.products);
            break;
        case 'refreshProducts':
            products = data.products;
            renderProducts();
            break;
    }
});

function openAdmin(productList) {
    products = productList || [];
    renderProducts();
    document.getElementById('container').classList.remove('hidden');
}

function closeAdmin() {
    document.getElementById('container').classList.add('hidden');
    closeModal();
    fetch(`https://${GetParentResourceName()}/closeMenu`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify({})
    }).catch(() => {}); // Ignore fetch errors
}

function renderProducts() {
    const grid = document.getElementById('products-grid');
    const emptyState = document.getElementById('empty-state');
    
    if (!products || products.length === 0) {
        grid.innerHTML = '';
        emptyState.classList.remove('hidden');
        return;
    }
    
    emptyState.classList.add('hidden');
    
    grid.innerHTML = products.map(product => `
        <div class="product-card">
            <img src="${product.imageUrl}" alt="${product.displayName}" class="product-image" onerror="this.src='data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjAwIiBoZWlnaHQ9IjE1MCIgdmlld0JveD0iMCAwIDIwMCAxNTAiIGZpbGw9Im5vbmUiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+CjxyZWN0IHdpZHRoPSIyMDAiIGhlaWdodD0iMTUwIiBmaWxsPSIjMUExQTFBIi8+Cjx0ZXh0IHg9IjEwMCIgeT0iNzUiIGZvbnQtZmFtaWx5PSJBcmlhbCIgZm9udC1zaXplPSIxNCIgZmlsbD0iIzY2NiIgdGV4dC1hbmNob3I9Im1pZGRsZSIgZG9taW5hbnQtYmFzZWxpbmU9Im1pZGRsZSI+QmlsZCBpbnRlIHRpbGxnw6RuZ2xpZzwvdGV4dD4KPC9zdmc+'">
            <div class="product-name">${product.displayName}</div>
            <div class="product-price">${product.price} coins</div>
            <div class="product-actions">
                <button class="edit-btn" onclick="editProduct(${product.id})">Redigera</button>
                <button class="delete-btn" onclick="deleteProduct(${product.id})">Ta bort</button>
            </div>
        </div>
    `).join('');
}

function openModal(isEdit = false) {
    const modal = document.getElementById('modal');
    const title = document.getElementById('modal-title');
    const saveBtn = document.getElementById('save-btn');
    
    title.textContent = isEdit ? 'Redigera produkt' : 'Lägg till produkt';
    saveBtn.textContent = isEdit ? 'Uppdatera' : 'Lägg till vara';
    
    modal.classList.remove('hidden');
}

function closeModal() {
    document.getElementById('modal').classList.add('hidden');
    document.getElementById('product-form').reset();
    editingProduct = null;
}

function editProduct(productId) {
    const product = products.find(p => p.id === productId);
    if (!product) return;
    
    editingProduct = product;
    
    document.getElementById('item-name').value = product.itemName;
    document.getElementById('display-name').value = product.displayName;
    document.getElementById('image-url').value = product.imageUrl;
    document.getElementById('price').value = product.price;
    
    openModal(true);
}

function deleteProduct(productId) {
    if (confirm('Är du säker på att du vill ta bort denna produkt?')) {
        fetch(`https://${GetParentResourceName()}/deleteProduct`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify({ productId: productId })
        });
    }
}

// Event Listeners
document.getElementById('add-btn').addEventListener('click', () => openModal(false));
document.getElementById('close-btn').addEventListener('click', closeAdmin);
document.getElementById('close-modal').addEventListener('click', closeModal);
document.getElementById('cancel-btn').addEventListener('click', closeModal);

document.getElementById('product-form').addEventListener('submit', function(e) {
    e.preventDefault();
    
    const formData = {
        itemName: document.getElementById('item-name').value.trim(),
        displayName: document.getElementById('display-name').value.trim(),
        imageUrl: document.getElementById('image-url').value.trim(),
        price: parseInt(document.getElementById('price').value)
    };
    
    if (!formData.itemName || !formData.displayName || !formData.imageUrl || !formData.price) {
        alert('Alla fält måste fyllas i.');
        return;
    }
    
    if (editingProduct) {
        formData.id = editingProduct.id;
        fetch(`https://${GetParentResourceName()}/updateProduct`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify(formData)
        });
    } else {
        fetch(`https://${GetParentResourceName()}/addProduct`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify(formData)
        });
    }
    
    closeModal();
});

// Close on escape key
document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        if (!document.getElementById('modal').classList.contains('hidden')) {
            closeModal();
        } else {
            closeAdmin();
        }
    }
});

// Utility function to get resource name
function GetParentResourceName() {
    return window.location.hostname;
}
