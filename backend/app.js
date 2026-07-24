const express = require('express');
const jwt = require('jsonwebtoken');
const connectDB = require('./config/db.js');
const User = require('./models/User.js');
const Course = require('./models/Course.js');
const auth = require('./middleware/auth.js');
const { generateRoadmap } = require('./agent.js');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;
const JWT_SECRET = process.env.JWT_SECRET || 'skillsprint_super_secret_jwt_key_2026';

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Connect to MongoDB
connectDB();

// Helper function to generate JWT Token
const generateToken = (id, email) => {
	return jwt.sign({ id, email }, JWT_SECRET, { expiresIn: '30d' });
};

app.get('/', (req, res) => {
	res.send("<h1>SkillSprint Backend (Auth & Ownership Protection Active)</h1>");
});

// ==================== AUTHENTICATION ROUTES ====================

// @route   POST /api/auth/register
// @desc    Register a new user & get JWT token
app.post('/api/auth/register', async (req, res) => {
	try {
		const { name, email, password } = req.body;

		if (!name || !email || !password) {
			return res.status(400).json({ success: false, error: 'Name, email, and password (min 6 chars) are required.' });
		}

		// Check if user exists
		const userExists = await User.findOne({ email });
		if (userExists) {
			return res.status(400).json({ success: false, error: 'User already exists with this email.' });
		}

		const user = await User.create({ name, email, password });
		const token = generateToken(user._id, user.email);

		res.status(201).json({
			success: true,
			user: {
				id: user._id,
				name: user.name,
				email: user.email,
			},
			token
		});
	} catch (error) {
		res.status(500).json({ success: false, error: error.message });
	}
});

// @route   POST /api/auth/login
// @desc    Authenticate user & get JWT token
app.post('/api/auth/login', async (req, res) => {
	try {
		const { email, password } = req.body;

		if (!email || !password) {
			return res.status(400).json({ success: false, error: 'Email and password are required.' });
		}

		const user = await User.findOne({ email });
		if (user && (await user.matchPassword(password))) {
			const token = generateToken(user._id, user.email);
			return res.json({
				success: true,
				user: {
					id: user._id,
					name: user.name,
					email: user.email,
				},
				token
			});
		} else {
			return res.status(401).json({ success: false, error: 'Invalid email or password.' });
		}
	} catch (error) {
		res.status(500).json({ success: false, error: error.message });
	}
});

// @route   GET /api/auth/me
// @desc    Get logged in user profile (Protected)
app.get('/api/auth/me', auth, async (req, res) => {
	try {
		const user = await User.findById(req.user.id).select('-password');
		if (!user) {
			return res.status(404).json({ success: false, error: 'User not found.' });
		}
		res.json({ success: true, user });
	} catch (error) {
		res.status(500).json({ success: false, error: error.message });
	}
});

// ==================== PROTECTED COURSE ROUTES ====================

// @route   POST /api/courses/generate
// @desc    Generate & Store Course for the LOGGED-IN User (Protected)
app.post('/api/courses/generate', auth, async (req, res) => {
	const { query } = req.body;

	if (!query) {
		return res.status(400).json({ success: false, error: 'Query prompt is required.' });
	}

	try {
		// Generate JSON from Gemini AI Agent
		const rawJsonText = await generateRoadmap({ prompt: query });
		const roadmapData = JSON.parse(rawJsonText);

		// Save Course in MongoDB linked directly to the authenticated user's ID
		const newCourse = await Course.create({
			userId: req.user.id,
			topic: roadmapData.topic || query,
			total_days: roadmapData.total_days,
			overview: roadmapData.overview,
			milestones: roadmapData.milestones,
			daily_plan: roadmapData.daily_plan,
			projects: roadmapData.projects,
			assessment: roadmapData.assessment,
			metadata: roadmapData.metadata
		});

		res.status(201).json({
			success: true,
			message: "Course generated and stored successfully",
			course: newCourse
		});
	} catch (error) {
		console.error("Error generating course:", error);
		res.status(500).json({ success: false, error: error.message });
	}
});

// @route   GET /api/courses
// @desc    Get all courses belonging to the LOGGED-IN User (Protected)
app.get('/api/courses', auth, async (req, res) => {
	try {
		const courses = await Course.find({ userId: req.user.id }).sort({ createdAt: -1 });
		res.json({ success: true, count: courses.length, courses });
	} catch (error) {
		res.status(500).json({ success: false, error: error.message });
	}
});

// @route   GET /api/courses/:courseId
// @desc    Get a single course details ONLY if owned by LOGGED-IN User (Protected & Authorized)
app.get('/api/courses/:courseId', auth, async (req, res) => {
	try {
		const course = await Course.findById(req.params.courseId).populate('userId', 'name email');
		
		if (!course) {
			return res.status(404).json({ success: false, error: "Course not found." });
		}

		// 🔒 BACKEND OWNERSHIP SECURITY CHECK
		if (course.userId._id.toString() !== req.user.id) {
			return res.status(403).json({ success: false, error: "Access Denied: You do not own this course." });
		}

		res.json({ success: true, course });
	} catch (error) {
		res.status(500).json({ success: false, error: error.message });
	}
});

// @route   DELETE /api/courses/:courseId
// @desc    Delete a course ONLY if owned by LOGGED-IN User (Protected & Authorized)
app.delete('/api/courses/:courseId', auth, async (req, res) => {
	try {
		const course = await Course.findById(req.params.courseId);

		if (!course) {
			return res.status(404).json({ success: false, error: "Course not found." });
		}

		// 🔒 BACKEND OWNERSHIP SECURITY CHECK
		if (course.userId.toString() !== req.user.id) {
			return res.status(403).json({ success: false, error: "Access Denied: You cannot delete a course you do not own." });
		}

		await course.deleteOne();
		res.json({ success: true, message: "Course deleted successfully." });
	} catch (error) {
		res.status(500).json({ success: false, error: error.message });
	}
});

// Legacy Endpoint (without auth header)
app.post('/generate', async (req, res) => {
	const prompt = req.body.query;
	try {
		const result = await generateRoadmap({ prompt });
		res.json({ success: true, data: JSON.parse(result) });
	} catch (error) {
		res.status(500).json({ success: false, error: error.message });
	}
});

app.listen(PORT, () => {
	console.log(`Server running on http://localhost:${PORT}`);
});
