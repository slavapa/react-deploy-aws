import React, { useEffect, useState } from 'react';
import ReactMarkdown from 'react-markdown';
import 'github-markdown-css';
import './App.css'; // Add your CSS styles here

function App() {
  const [markdown, setMarkdown] = useState('');

  useEffect(() => {
    fetch('/README.md')
      .then((response) => response.text())
      .then((text) => setMarkdown(text));
  }, []);

  return (
    <div className="markdown-body" style={{ padding: '20px' }}>
      <ReactMarkdown>{markdown}</ReactMarkdown>
    </div>
  );
}

export default App;
