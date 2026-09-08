import Foundation

struct WebSecurityScripts {
    static let dlpScript = """
        // 1. Disable text copying, cut, selecting, and context menu
        const style = document.createElement('style');
        style.type = 'text/css';
        style.innerHTML = '* { -webkit-user-select: none !important; -webkit-touch-callout: none !important; }';
        document.head.appendChild(style);

        document.addEventListener('copy', (e) => { e.preventDefault(); e.stopPropagation(); }, true);
        document.addEventListener('cut', (e) => { e.preventDefault(); e.stopPropagation(); }, true);
        document.addEventListener('contextmenu', (e) => { e.preventDefault(); e.stopPropagation(); }, true);
        document.addEventListener('dragstart', (e) => { e.preventDefault(); e.stopPropagation(); }, true);

        // 2. Prevent blob and download conversions
        window.open = function(url) {
            if (url && (url.startsWith('blob:') || url.includes('download'))) {
                console.log('Blocked download attempt: ' + url);
                return null;
            }
            return window.location.href = url;
        };
    """
}