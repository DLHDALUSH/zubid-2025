// Performance Optimization Utilities

// Debounce function for expensive operations
function debounce(func, wait) {
    let timeout;
    return function executedFunction(...args) {
        const later = () => {
            clearTimeout(timeout);
            func(...args);
        };
        clearTimeout(timeout);
        timeout = setTimeout(later, wait);
    };
}

// Throttle function for frequent events
function throttle(func, limit) {
    let inThrottle;
    return function(...args) {
        if (!inThrottle) {
            func.apply(this, args);
            inThrottle = true;
            setTimeout(() => inThrottle = false, limit);
        }
    };
}

// Request Animation Frame Throttle
function rafThrottle(func) {
    let rafId = null;
    return function(...args) {
        if (rafId === null) {
            rafId = requestAnimationFrame(() => {
                func(...args);
                rafId = null;
            });
        }
    };
}

// Image Preloader
const ImagePreloader = {
    cache: new Set(),
    
    preload(url) {
        if (this.cache.has(url)) return Promise.resolve();
        
        return new Promise((resolve, reject) => {
            const img = new Image();
            img.onload = () => {
                this.cache.add(url);
                resolve(img);
            };
            img.onerror = reject;
            img.src = url;
        });
    },
    
    preloadBatch(urls) {
        return Promise.allSettled(urls.map(url => this.preload(url)));
    }
};

// Resource Hints Manager
const ResourceHints = {
    addPrefetch(url, as = 'document') {
        const link = document.createElement('link');
        link.rel = 'prefetch';
        link.as = as;
        link.href = url;
        document.head.appendChild(link);
    },
    
    addPreconnect(domain) {
        const link = document.createElement('link');
        link.rel = 'preconnect';
        link.href = domain;
        document.head.appendChild(link);
    },
    
    addDNSPrefetch(domain) {
        const link = document.createElement('link');
        link.rel = 'dns-prefetch';
        link.href = domain;
        document.head.appendChild(link);
    }
};

// Performance Monitor
const PerformanceMonitor = {
    metrics: {},
    
    mark(name) {
        if ('performance' in window && 'mark' in performance) {
            performance.mark(name);
        }
    },
    
    measure(name, startMark, endMark) {
        if ('performance' in window && 'measure' in performance) {
            try {
                performance.measure(name, startMark, endMark);
                const measure = performance.getEntriesByName(name, 'measure')[0];
                this.metrics[name] = measure.duration;
                return measure.duration;
            } catch (e) {
                console.warn('Performance measure failed:', e);
            }
        }
        return null;
    },
    
    getMetrics() {
        return { ...this.metrics };
    },
    
    getPageLoadTime() {
        if ('performance' in window && 'timing' in performance) {
            const timing = performance.timing;
            return timing.loadEventEnd - timing.navigationStart;
        }
        return null;
    }
};

// Batch DOM Updates
const DOMBatcher = {
    queue: [],
    scheduled: false,
    
    add(updateFn) {
        this.queue.push(updateFn);
        if (!this.scheduled) {
            this.scheduled = true;
            requestAnimationFrame(() => {
                this.flush();
            });
        }
    },
    
    flush() {
        const updates = this.queue.splice(0);
        updates.forEach(fn => {
            try {
                fn();
            } catch (e) {
                console.error('DOM update error:', e);
            }
        });
        this.scheduled = false;
        if (this.queue.length > 0) {
            this.scheduled = true;
            requestAnimationFrame(() => this.flush());
        }
    }
};

// Export
if (typeof window !== 'undefined') {
    window.debounce = debounce;
    window.throttle = throttle;
    window.rafThrottle = rafThrottle;
    window.ImagePreloader = ImagePreloader;
    window.ResourceHints = ResourceHints;
    window.PerformanceMonitor = PerformanceMonitor;
    window.DOMBatcher = DOMBatcher;
}

