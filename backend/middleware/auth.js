const jwt = require('jsonwebtoken');

const auth = (req, res, next) => {
  let token;

  if (
    req.headers.authorization &&
    req.headers.authorization.startsWith('Bearer')
  ) {
    token = req.headers.authorization.split(' ')[1];
  }

  if (!token) {
    return res.status(401).json({
      success: false,
      error: 'Not authorized: No authentication token provided.',
    });
  }

  try {
    const decoded = jwt.verify(
      token,
      process.env.JWT_SECRET || 'skillsprint_super_secret_jwt_key_2026'
    );
    req.user = decoded; // { id: userId, email: userEmail }
    next();
  } catch (error) {
    return res.status(401).json({
      success: false,
      error: 'Not authorized: Invalid or expired token.',
    });
  }
};

module.exports = auth;
