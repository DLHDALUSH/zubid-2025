// Admin Categories Management
document.addEventListener('DOMContentLoaded', async () => {
    await checkAdminAuth();
    await loadCategories();
});

async function loadCategories() {
    const tbody = document.getElementById('categoriesTableBody');
    tbody.innerHTML = '<tr><td colspan="4" class="loading">Loading categories...</td></tr>';
    
    try {
        const categories = await CategoryAPI.getAll();
        
        if (categories && categories.length > 0) {
            // Escape HTML utility
            const escapeHtml = (text) => {
                if (text == null) return '';
                const div = document.createElement('div');
                div.textContent = text;
                return div.innerHTML;
            };
            
            tbody.innerHTML = categories.map(cat => {
                const nameEscaped = escapeHtml(cat.name || '');
                const descEscaped = escapeHtml(cat.description || '');
                return `
                <tr>
                    <td>${cat.id}</td>
                    <td>${nameEscaped}</td>
                    <td>${descEscaped || '-'}</td>
                    <td class="actions">
                        <button class="btn btn-small btn-primary edit-category-btn" 
                                data-category-id="${cat.id}" 
                                data-name="${nameEscaped}" 
                                data-description="${descEscaped}">Edit</button>
                        <button class="btn btn-small btn-danger delete-category-btn" 
                                data-category-id="${cat.id}">Delete</button>
                    </td>
                </tr>
            `;
            }).join('');
            
            // Attach event listeners after rendering
            tbody.querySelectorAll('.edit-category-btn').forEach(btn => {
                btn.addEventListener('click', function() {
                    const id = parseInt(this.dataset.categoryId);
                    const name = this.dataset.name;
                    const description = this.dataset.description;
                    editCategory(id, name, description);
                });
            });
            
            tbody.querySelectorAll('.delete-category-btn').forEach(btn => {
                btn.addEventListener('click', function() {
                    const id = parseInt(this.dataset.categoryId);
                    deleteCategory(id);
                });
            });
        } else {
            tbody.innerHTML = '<tr><td colspan="4">No categories found</td></tr>';
        }
    } catch (error) {
        if (window.utils) window.utils.debugError('Error loading categories:', error);
        const errorMsg = error.message || 'Unknown error';
        // Escape error message to prevent XSS
        const escapeHtml = (text) => {
            if (text == null) return '';
            const div = document.createElement('div');
            div.textContent = text;
            return div.innerHTML;
        };
        tbody.innerHTML = `<tr><td colspan="4">Error: ${escapeHtml(errorMsg)}</td></tr>`;
        showToast('Error loading categories', 'error');
    }
}

async function handleAddCategory(event) {
    event.preventDefault();
    
    const name = document.getElementById('categoryName').value;
    const description = document.getElementById('categoryDescription').value;
    
    try {
        const API_BASE = (window.API_BASE_URL || 'http://localhost:5000/api').replace('/api', '');
        const response = await fetch(`${API_BASE}/api/admin/categories`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            credentials: 'include',
            body: JSON.stringify({ name, description })
        });
        
        if (!response.ok) {
            const error = await response.json();
            throw new Error(error.error || 'Failed to create category');
        }
        
        showToast('Category created successfully', 'success');
        document.getElementById('addCategoryForm').reset();
        await loadCategories();
    } catch (error) {
        showToast(error.message || 'Failed to create category', 'error');
    }
}

function editCategory(categoryId, name, description) {
    document.getElementById('editCategoryId').value = categoryId;
    document.getElementById('editCategoryName').value = name;
    document.getElementById('editCategoryDescription').value = description;
    document.getElementById('editCategoryModal').style.display = 'block';
}

async function handleUpdateCategory(event) {
    event.preventDefault();
    
    const categoryId = document.getElementById('editCategoryId').value;
    const name = document.getElementById('editCategoryName').value;
    const description = document.getElementById('editCategoryDescription').value;
    
    try {
        const API_BASE = (window.API_BASE_URL || 'http://localhost:5000/api').replace('/api', '');
        const response = await fetch(`${API_BASE}/api/admin/categories/${categoryId}`, {
            method: 'PUT',
            headers: { 'Content-Type': 'application/json' },
            credentials: 'include',
            body: JSON.stringify({ name, description })
        });
        
        if (!response.ok) {
            const error = await response.json();
            throw new Error(error.error || 'Failed to update category');
        }
        
        showToast('Category updated successfully', 'success');
        closeModal('editCategoryModal');
        await loadCategories();
    } catch (error) {
        showToast(error.message || 'Failed to update category', 'error');
    }
}

async function deleteCategory(categoryId) {
    if (!confirm('Are you sure you want to delete this category? Auctions using this category may be affected.')) {
        return;
    }
    
    try {
        const API_BASE = (window.API_BASE_URL || 'http://localhost:5000/api').replace('/api', '');
        const response = await fetch(`${API_BASE}/api/admin/categories/${categoryId}`, {
            method: 'DELETE',
            credentials: 'include'
        });
        
        if (!response.ok) {
            const error = await response.json();
            throw new Error(error.error || 'Failed to delete category');
        }
        
        showToast('Category deleted successfully', 'success');
        await loadCategories();
    } catch (error) {
        showToast(error.message || 'Failed to delete category', 'error');
    }
}

function closeModal(modalId) {
    document.getElementById(modalId).style.display = 'none';
}

window.onclick = function(event) {
    const modals = document.querySelectorAll('.modal');
    modals.forEach(modal => {
        if (event.target === modal) {
            modal.style.display = 'none';
        }
    });
};

