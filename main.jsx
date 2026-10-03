import React from 'react'
import ReactDOM from 'react-dom/client'
import App from './App.jsx'
import './index.css'

class ErrorBoundary extends React.Component {
  constructor(props) {
    super(props);
    this.state = { hasError: false, error: null };
  }

  static getDerivedStateFromError(error) {
    return { hasError: true, error };
  }

  componentDidCatch(error, errorInfo) {
    console.error("ErrorBoundary caught:", error, errorInfo);
  }

  handleReset = () => {
    try {
      localStorage.clear();
      sessionStorage.clear();
    } catch (_) {}
    window.location.href = '/login';
  };

  render() {
    if (this.state.hasError) {
      return (
        <div style={{
          minHeight: '100vh',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          backgroundColor: '#020617',
          color: '#f8fafc',
          fontFamily: 'system-ui, -apple-system, sans-serif',
          padding: '24px'
        }}>
          <div style={{
            maxWidth: '460px',
            width: '100%',
            backgroundColor: '#0f172a',
            borderRadius: '20px',
            padding: '36px 30px',
            border: '1px solid #1e293b',
            boxShadow: '0 25px 50px -12px rgba(0, 0, 0, 0.5)',
            textAlign: 'center'
          }}>
            <div style={{
              width: '52px',
              height: '52px',
              margin: '0 auto 16px',
              borderRadius: '14px',
              backgroundColor: 'rgba(239, 68, 68, 0.1)',
              border: '1px solid rgba(239, 68, 68, 0.2)',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              color: '#f87171',
              fontSize: '24px'
            }}>
              ⚠️
            </div>
            <h2 style={{ fontSize: '18px', fontWeight: 'bold', margin: '0 0 8px', color: '#ffffff' }}>
              SCAN TO SECURE
            </h2>
            <p style={{ fontSize: '13px', color: '#94a3b8', margin: '0 0 20px', lineHeight: '1.5' }}>
              Your browser stored an outdated session state. Click below to refresh your connection.
            </p>
            <button
              onClick={this.handleReset}
              style={{
                width: '100%',
                backgroundColor: '#4f46e5',
                color: '#ffffff',
                border: 'none',
                borderRadius: '12px',
                padding: '12px 20px',
                fontSize: '13px',
                fontWeight: '600',
                cursor: 'pointer',
                transition: 'all 0.2s'
              }}
            >
              Reset Session & Open Login
            </button>
          </div>
        </div>
      );
    }
    return this.props.children;
  }
}

ReactDOM.createRoot(document.getElementById('root')).render(
  <React.StrictMode>
    <ErrorBoundary>
      <App />
    </ErrorBoundary>
  </React.StrictMode>,
)
