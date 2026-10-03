import React from 'react';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { AuthProvider, useAuth } from './context/AuthContext';
import ProtectedRoute from './components/common/ProtectedRoute';
import DashboardLayout from './layouts/DashboardLayout';

// Auth Pages
import LoginPage from './pages/auth/LoginPage';
import RegisterPage from './pages/auth/RegisterPage';

// Student Pages
import StudentDashboard from './pages/student/StudentDashboard';
import MyCertificatesPage from './pages/student/MyCertificatesPage';
import UploadCertificatePage from './pages/student/UploadCertificatePage';

// Professor Pages
import ProfessorDashboard from './pages/professor/ProfessorDashboard';
import ClassFoldersPage from './pages/professor/ClassFoldersPage';
import CertificateReviewPage from './pages/professor/CertificateReviewPage';

// Admin Pages
import AdminDashboard from './pages/admin/AdminDashboard';
import UsersPage from './pages/admin/UsersPage';
import AuditLogsPage from './pages/admin/AuditLogsPage';

// Smart Dashboard component that directs user to their role-specific view
const RoleDashboardRouter = () => {
  const { user } = useAuth();
  if (!user) return null;

  if (user.role === 'admin') return <AdminDashboard />;
  if (user.role === 'professor') return <ProfessorDashboard />;
  return <StudentDashboard />;
};

// Smart Certificates Router
const RoleCertificatesRouter = () => {
  const { user } = useAuth();
  if (!user) return null;

  if (user.role === 'student') return <MyCertificatesPage />;
  if (user.role === 'professor') return <CertificateReviewPage />;
  return <MyCertificatesPage />;
};

function App() {
  return (
    <AuthProvider>
      <BrowserRouter>
        <Routes>
          {/* Public Routes */}
          <Route path="/login" element={<LoginPage />} />
          <Route path="/register" element={<RegisterPage />} />

          {/* Protected Application Layout */}
          <Route
            path="/"
            element={
              <ProtectedRoute>
                <DashboardLayout />
              </ProtectedRoute>
            }
          >
            {/* Index redirects to Dashboard */}
            <Route index element={<Navigate to="/dashboard" replace />} />
            <Route path="dashboard" element={<RoleDashboardRouter />} />
            
            {/* Student & Shared Routes */}
            <Route path="certificates" element={<RoleCertificatesRouter />} />
            <Route 
              path="upload" 
              element={
                <ProtectedRoute allowedRoles={['student', 'admin']}>
                  <UploadCertificatePage />
                </ProtectedRoute>
              } 
            />

            {/* Professor & Academic Routes */}
            <Route 
              path="classes" 
              element={
                <ProtectedRoute allowedRoles={['professor', 'admin', 'student']}>
                  <ClassFoldersPage />
                </ProtectedRoute>
              } 
            />
            <Route 
              path="classes/:classId" 
              element={
                <ProtectedRoute allowedRoles={['professor', 'admin', 'student']}>
                  <ClassFoldersPage />
                </ProtectedRoute>
              } 
            />
            <Route 
              path="submissions" 
              element={
                <ProtectedRoute allowedRoles={['professor', 'admin']}>
                  <CertificateReviewPage />
                </ProtectedRoute>
              } 
            />

            {/* Admin Routes */}
            <Route 
              path="admin/users" 
              element={
                <ProtectedRoute allowedRoles={['admin']}>
                  <UsersPage />
                </ProtectedRoute>
              } 
            />
            <Route 
              path="admin/logs" 
              element={
                <ProtectedRoute allowedRoles={['admin']}>
                  <AuditLogsPage />
                </ProtectedRoute>
              } 
            />
          </Route>

          {/* Catch-all fallback */}
          <Route path="*" element={<Navigate to="/dashboard" replace />} />
        </Routes>
      </BrowserRouter>
    </AuthProvider>
  );
}

export default App;
