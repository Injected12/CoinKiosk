let currentCoins = 0;
let products = [];

// Listen for messages from Lua
window.addEventListener('message', function(event) {
    const data = event.data;
    
    switch(data.type) {
        case 'openShop':
            openShop(data.coins, data.products);
            break;
        case 'closeShop':
            closeShop();
            break;
    }
});

function openShop(coins, productList) {
    currentCoins = coins;
    products = productList;
    
    document.getElementById('coin-amount').textContent = coins;
    renderProducts();
    document.getElementById('container').classList.remove('hidden');
}

function closeShop() {
    document.getElementById('container').classList.add('hidden');
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
        <div class="product-card" onclick="purchaseItem(${product.id})">
            <img src="${product.imageUrl}" alt="${product.displayName}" class="product-image" onerror="this.src='data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjAwIiBoZWlnaHQ9IjE1MCIgdmlld0JveD0iMCAwIDIwMCAxNTAiIGZpbGw9Im5vbmUiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+CjxyZWN0IHdpZHRoPSIyMDAiIGhlaWdodD0iMTUwIiBmaWxsPSIjMUExQTFBIi8+Cjx0ZXh0IHg9IjEwMCIgeT0iNzUiIGZvbnQtZmFtaWx5PSJBcmlhbCIgZm9udC1zaXplPSIxNCIgZmlsbD0iIzY2NiIgdGV4dC1hbmNob3I9Im1pZGRsZSIgZG9taW5hbnQtYmFzZWxpbmU9Im1pZGRsZSI+QmlsZCBpbnRlIHRpbGxnw6RuZ2xpZzwvdGV4dD4KPC9zdmc+'">
            <div class="product-name">${product.displayName}</div>
            <div class="product-price">${product.price} coins</div>
            <button class="buy-btn ${currentCoins >= product.price ? 'can-buy' : 'cannot-buy'}">
                ${currentCoins >= product.price ? 'Köp' : 'Inte nog med Coins'}
            </button>
        </div>
    `).join('');
}

function purchaseItem(productId) {
    const product = products.find(p => p.id === productId);
    if (!product || currentCoins < product.price) {
        return;
    }
    
    fetch(`https://${GetParentResourceName()}/purchaseItem`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify({ productId: productId })
    });
    
    closeShop();
}

// Close button event
document.getElementById('close-btn').addEventListener('click', closeShop);

// Close on escape key
document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        closeShop();
    }
});

// Utility function to get resource name
function GetParentResourceName() {
    return window.location.hostname;
}
