'use strict';

const express = require('express');

const app = express();
const PORT = parseInt(process.env.PORT, 10) || 3000;

app.use(express.json());

// In-memory data store for demonstration
const USERS_STORE = [
  { id: 1, username: 'alice.johnson', role: 'admin', active: true },
  { id: 2, username: 'bob.smith', role: 'developer', active: true },
  { id: 3, username: 'carol.danvers', role: 'viewer', active: false }
];

/**
 * Health check endpoint for uptime and container readiness.
 */
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'UP',
    timestamp: new Date().toISOString(),
    uptimeSeconds: Math.floor(process.uptime())
  });
});

/**
 * User directory retrieval endpoint with optional role query filter.
 */
app.get('/api/users', (req, res) => {
  const { role } = req.query;

  if (role && typeof role === 'string') {
    const filteredUsers = USERS_STORE.filter((user) => user.role.toLowerCase() === role.toLowerCase());
    return res.status(200).json({ total: filteredUsers.length, users: filteredUsers });
  }

  res.status(200).json({ total: USERS_STORE.length, users: USERS_STORE });
});

/**
 * Creates a new user record with standard payload validation.
 */
app.post('/api/users', (req, res) => {
  const { username, role } = req.body || {};

  if (!username || typeof username !== 'string' || username.trim().length < 3) {
    return res.status(400).json({ error: 'Valid username of at least 3 characters is required' });
  }

  const validRoles = ['admin', 'developer', 'viewer'];
  const userRole = (role && validRoles.includes(role.toLowerCase())) ? role.toLowerCase() : 'viewer';

  const newUser = {
    id: USERS_STORE.length + 1,
    username: username.trim(),
    role: userRole,
    active: true
  };

  USERS_STORE.push(newUser);
  res.status(201).json(newUser);
});

if (require.main === module) {
  app.listen(PORT, () => {
    console.log(`User directory service listening on port ${PORT}`);
  });
}

module.exports = app;
