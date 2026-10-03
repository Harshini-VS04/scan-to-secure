import React, { createContext, useContext, useState, useEffect } from 'react';
import api from '../api/client';

const AuthContext = createContext(null);

export const AuthProvider = ({ children }) => {
  const [user, setUser] = useState(() => {
    try {
      const saved = localStorage.getItem('user');
      if (saved && saved !== 'undefined' && saved !== 'null') {
        return JSON.parse(saved);
      }
    } catch (e) {
      console.error("Auth init: clearing corrupted user stored in localStorage", e);
      try { localStorage.removeItem('user'); } catch (_) {}
    }
    return null;
  });

  const [token, setToken] = useState(() => {
    try {
      const saved = localStorage.getItem('token');
      if (saved && saved !== 'undefined' && saved !== 'null') {
        return saved;
      }
    } catch (e) {
      try { localStorage.removeItem('token'); } catch (_) {}
    }
    return null;
  });

  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    const verifyAuth = async () => {
      const storedToken = localStorage.getItem('token');
      if (storedToken && storedToken !== 'undefined' && storedToken !== 'null') {
        try {
          const res = await api.get('/auth/me');
          setUser(res.data);
          localStorage.setItem('user', JSON.stringify(res.data));
        } catch (err) {
          console.error("Auth check failed:", err);
          logout();
        }
      } else {
        logout();
      }
      setIsLoading(false);
    };
    verifyAuth();
  }, []);

  const login = async (email, password) => {
    const res = await api.post('/auth/login', { email, password });
    const { access_token, user: loggedInUser } = res.data;
    localStorage.setItem('token', access_token);
    localStorage.setItem('user', JSON.stringify(loggedInUser));
    setToken(access_token);
    setUser(loggedInUser);
    return loggedInUser;
  };

  const logout = () => {
    localStorage.removeItem('token');
    localStorage.removeItem('user');
    setToken(null);
    setUser(null);
  };

  const hasRole = (roles) => {
    if (!user) return false;
    if (Array.isArray(roles)) {
      return roles.includes(user.role);
    }
    return user.role === roles;
  };

  return (
    <AuthContext.Provider
      value={{
        user,
        token,
        isAuthenticated: !!user,
        isLoading,
        login,
        logout,
        hasRole
      }}
    >
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
};
