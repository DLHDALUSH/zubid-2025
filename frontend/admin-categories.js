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
            tbody.innerHTML = categories.map(cat => `
                <tr>
                    <td>${cat.id}</td>
                    <td>${cat.name}</td>
                    <td>${cat.description || '-'}</td>
                    <td class="actions">
                        <button class="btn btn-small btn-primary" onclick="editCategory(${cat.id}, '${cat.name.replace(/'/g, "\\'")}', '${(cat.description || '').replace(/'/g, "\\'")}')">Edit</button>
                        <button class="btn btn-small btn-danger" onclick="deleteCategory(${cat.id})">Delete</button>
                    </td>
                </tr>
            `).join('');
        } else {
            tbody.innerHTML = '<tr><td colspan="4">No categories found</td></tr>';
        }
    } catch (error) {
        console.error('Error loading categories:', error);
        tbody.innerHTML = `<tr><td colspan="4">Error: ${error.message}</td></tr>`;
        showToast('Error loading categories', 'error');
    }
}

async function handleAddCategory(event) {
    event.preventDefault();
    
    const name = document.getElementById('categoryName').value;
    const description = document.getElementById('categoryDescription').value;
    
    try {
        const response = await fetch('http://localhost:5000/api/admin/categories', {
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
        const response = await fetch(`http://localhost:5000/api/admin/categories/${categoryId}`, {
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
        const response = await fetch(`http://localhost:5000/api/admin/categories/${categoryId}`, {
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

