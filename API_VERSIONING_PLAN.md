# 🔄 API Versioning Implementation Plan

## 📊 Current Status

- **Total API Routes:** 76 routes
- **Current Pattern:** `/api/endpoint`
- **Target Pattern:** `/api/v1/endpoint`
- **Backward Compatibility:** Required (don't break existing clients)

---

## 🎯 Implementation Strategy

### Option 1: Flask Blueprint with URL Prefix (Recommended)

**Pros:**
- ✅ Minimal code changes
- ✅ Easy to maintain
- ✅ Can support multiple versions simultaneously
- ✅ Backward compatible

**Cons:**
- ⚠️ Requires some refactoring

**Implementation:**
1. Create a Blueprint for API v1
2. Register blueprint with `/api/v1` prefix
3. Keep existing routes for backward compatibility
4. Gradually migrate clients to v1

### Option 2: URL Rewrite Middleware

**Pros:**
- ✅ Zero code changes to routes
- ✅ Instant versioning

**Cons:**
- ⚠️ Less explicit
- ⚠️ Harder to maintain multiple versions

### Option 3: Manual Route Updates

**Pros:**
- ✅ Most explicit

**Cons:**
- ❌ 76 routes to update manually
- ❌ High risk of errors
- ❌ Time-consuming

---

## 🚀 Recommended Approach: Hybrid Solution

### Phase 1: Add URL Rewrite Middleware (Immediate)

Add middleware that accepts both `/api/endpoint` and `/api/v1/endpoint`:

```python
@app.before_request
def handle_api_versioning():
    # Rewrite /api/v1/* to /api/* internally
    if request.path.startswith('/api/v1/'):
        request.environ['PATH_INFO'] = request.path.replace('/api/v1/', '/api/', 1)
```

**Benefits:**
- ✅ Works immediately
- ✅ No route changes needed
- ✅ Clients can use either `/api/` or `/api/v1/`
- ✅ Backward compatible

### Phase 2: Blueprint Refactoring (Future)

When ready to support v2, refactor to use Blueprints:

```python
# api_v1.py
api_v1 = Blueprint('api_v1', __name__, url_prefix='/api/v1')

@api_v1.route('/auctions', methods=['GET'])
def get_auctions():
    # ...

# api_v2.py
api_v2 = Blueprint('api_v2', __name__, url_prefix='/api/v2')

@api_v2.route('/auctions', methods=['GET'])
def get_auctions_v2():
    # New implementation with breaking changes
```

---

## 📝 Implementation Steps

### Step 1: Add Versioning Middleware

Add this code to `backend/app.py` after app initialization:

```python
# API Versioning Middleware
@app.before_request
def handle_api_versioning():
    """
    Handle API versioning by rewriting URLs.
    Supports both /api/endpoint and /api/v1/endpoint
    """
    path = request.path
    
    # Rewrite /api/v1/* to /api/* for backward compatibility
    if path.startswith('/api/v1/'):
        request.environ['PATH_INFO'] = path.replace('/api/v1/', '/api/', 1)
        # Store original version in request context
        g.api_version = 'v1'
    elif path.startswith('/api/'):
        # Default to v1 for unversioned requests
        g.api_version = 'v1'
    
    # Log API version for debugging
    if app.debug and path.startswith('/api/'):
        app.logger.debug(f'API Request: {request.method} {path} (version: {g.api_version})')
```

### Step 2: Add Version Header to Responses

```python
@app.after_request
def add_api_version_header(response):
    """Add API version to response headers"""
    if hasattr(g, 'api_version'):
        response.headers['X-API-Version'] = g.api_version
    return response
```

### Step 3: Update Frontend Configuration

Update `frontend/config.js` to use `/api/v1`:

```javascript
development: {
    apiUrl: 'http://localhost:5000/api/v1',
    // ...
},
production: {
    apiUrl: 'https://zubid-2025.onrender.com/api/v1',
    // ...
}
```

### Step 4: Update Flutter Configuration

Update `mobile/flutter_zubid/lib/core/config/app_config.dart`:

```dart
static String get apiUrl => '$baseUrl/api/v1';
```

### Step 5: Test Both Versions

Test that both URLs work:
- `/api/auctions` ✅ (backward compatible)
- `/api/v1/auctions` ✅ (new versioned URL)

---

## 🧪 Testing Checklist

- [ ] Test all 76 endpoints with `/api/v1/` prefix
- [ ] Test backward compatibility with `/api/` prefix
- [ ] Verify `X-API-Version` header in responses
- [ ] Test frontend with new API URLs
- [ ] Test Flutter app with new API URLs
- [ ] Check CORS configuration still works
- [ ] Verify CSRF tokens work with versioned URLs
- [ ] Test authentication flow
- [ ] Test file uploads
- [ ] Test WebSocket connections (if applicable)

---

## 📋 Migration Timeline

### Week 1: Backend Implementation
- [ ] Add versioning middleware
- [ ] Add version headers
- [ ] Test all endpoints
- [ ] Deploy to staging

### Week 2: Client Updates
- [ ] Update frontend to use `/api/v1`
- [ ] Update Flutter app to use `/api/v1`
- [ ] Test all client functionality
- [ ] Deploy to production

### Week 3: Monitoring
- [ ] Monitor API usage
- [ ] Check for errors
- [ ] Verify both versions work
- [ ] Document any issues

### Week 4: Deprecation Notice (Optional)
- [ ] Add deprecation warning for `/api/` (unversioned)
- [ ] Set sunset date for unversioned API
- [ ] Notify users to migrate

---

## 🔮 Future: API v2 Planning

When you need breaking changes, create v2:

### Breaking Changes That Warrant v2:
- Changing response structure
- Removing fields
- Changing authentication method
- Changing error format
- Major database schema changes

### Non-Breaking Changes (Stay in v1):
- Adding new fields
- Adding new endpoints
- Bug fixes
- Performance improvements
- Adding optional parameters

---

## 📚 API Versioning Best Practices

1. **Semantic Versioning:** Use v1, v2, v3 (not v1.1, v1.2)
2. **Deprecation Period:** Give clients 6-12 months to migrate
3. **Documentation:** Document changes between versions
4. **Version Header:** Always include `X-API-Version` in responses
5. **Default Version:** Unversioned URLs should use latest stable version
6. **Sunset Header:** Add `Sunset` header for deprecated versions

---

## 🎉 Benefits of This Approach

1. **Backward Compatible:** Existing clients continue to work
2. **Future-Proof:** Easy to add v2, v3 later
3. **Minimal Changes:** No need to update 76 routes immediately
4. **Flexible:** Supports gradual migration
5. **Professional:** Industry-standard approach
6. **Testable:** Can test both versions simultaneously

---

## 📞 Next Steps

1. Review this plan
2. Implement Phase 1 (middleware)
3. Test thoroughly
4. Update clients
5. Monitor and iterate

**Estimated Time:** 4-6 hours total
**Risk Level:** Low (backward compatible)
**Impact:** High (future-proofs API)

---

**Created:** January 3, 2026
**Status:** Ready for Implementation

