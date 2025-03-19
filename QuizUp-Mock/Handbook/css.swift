//
//  css.swift
//  Life In The UK Prep
//
//  Created by Edwin Bosire on 15/03/2025.
//

import Foundation
let css = """
<style>
	:root {
		color-scheme: light;
	}
	
	body {
		font-family: -apple-system, BlinkMacSystemFont, 'SF Pro', 'SF Pro Text', 'San Francisco', system-ui, sans-serif;
		font-size: 16px;
		line-height: 1.5;
		color: rgba(0, 0, 0, 0.85);
		margin: 0;
		padding: 16px;
		user-select: text;
		-webkit-user-select: text;
	}
	
	h1 {
		font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Display', 'SF Pro', system-ui, sans-serif;
		font-size: 26px;
		font-weight: bold;
		margin-bottom: 12px;
		#position: -webkit-sticky; /* For Safari */
		#position: sticky;
		#top: 0;
		#background-color: rgba(255, 255, 255, 1.0);
	}
	
	h2 {
		font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Display', 'SF Pro', system-ui, sans-serif;
		font-size: 20px;
		font-weight: 700;
		margin-top: 24px;
		margin-bottom: 8px;
		position: -webkit-sticky; /* For Safari */
		position: sticky;
		top: 0;
		background-color: rgba(255, 255, 255, 1.0);

	}
	h3 {
		font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Display', 'SF Pro', system-ui, sans-serif;
		font-size: 18px;
		font-weight: 600;
		margin-top: 16px;
		margin-bottom: 8px;
		position: -webkit-sticky; /* For Safari */
		position: sticky;
		top: 0;
		background-color: rgba(255, 255, 255, 1.0);

	}

	p {
		margin-bottom: 16px;
		user-select: text;
		-webkit-user-select: text;
	}
	
	ul {
		#padding: 2px;
		#padding-top: 16px;
		#padding-left: 24px;
		margin-bottom: 16px;
		background-color: rgba(0, 0, 0, 0.05);
		border-radius: 10px
	}
	
	li {
		text-transform: capitalize;
		margin-bottom: 8px;
		padding: 4px;

	}
	
	blockquote {
		margin: 16px 0;
		padding: 12px 16px;
		background-color: rgba(0, 0, 0, 0.05);
		border-left: 4px solid rgba(0, 0, 0, 0.1);
		font-style: italic;
	}
	
	a {
		color: #007AFF;
		text-decoration: none;
	}
	
	img {
		max-width: 100%;
		height: auto;
		border-radius: 4px;
	}
	  /* Highlight styles */
	  .highlighted {
		  border-radius: 2px;
		  padding: 0 1px;
		  margin: 0 -1px;
	  }
	  
	  .highlight-yellow {
		  background-color: rgba(255, 235, 59, 0.5);
	  }
	  
	  .highlight-green {
		  background-color: rgba(76, 175, 80, 0.3);
	  }
	  
	  .highlight-blue {
		  background-color: rgba(33, 150, 243, 0.3);
	  }
	  
	  .highlight-pink {
		  background-color: rgba(233, 30, 99, 0.3);
	  }
	  
	  /* Highlight context menu */
	  .highlight-menu {
		  position: absolute;
		  background-color: #ffffff;
		  border-radius: 8px;
		  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.2);
		  padding: 8px;
		  display: flex;
		  z-index: 1000;
	  }
	  
	  .highlight-menu button {
		  width: 24px;
		  height: 24px;
		  border-radius: 12px;
		  border: 1px solid rgba(0, 0, 0, 0.1);
		  margin: 0 4px;
		  cursor: pointer;
	  }
	  
	  .highlight-menu .yellow {
		  background-color: #FFEB3B;
	  }
	  
	  .highlight-menu .green {
		  background-color: #4CAF50;
	  }
	  
	  .highlight-menu .blue {
		  background-color: #2196F3;
	  }
	  
	  .highlight-menu .pink {
		  background-color: #E91E63;
	  }
	  
	  .highlight-menu .remove {
		  background-color: #ffffff;
		  color: #FF5722;
		  font-weight: bold;
		  font-size: 16px;
		  display: flex;
		  align-items: center;
		  justify-content: center;
	  }

	/* Dark mode support */
	@media (prefers-color-scheme: dark) {
		:root {
			color-scheme: dark;
		}
		
		body {
			background-color: #1a1a1a;
			color: rgba(255, 255, 255, 0.9);
		}
		
		blockquote {
			background-color: rgba(255, 255, 255, 0.1);
			border-left-color: rgba(255, 255, 255, 0.2);
		}
		
		a {
			color: #0A84FF;
		}
		
	  .highlight-menu {
		  background-color: #333;
		  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.5);
	  }
	  
	  .highlight-menu .remove {
		  background-color: #333;
	  }
	  
	  /* Adjust highlight colors for dark mode */
	  .highlight-yellow {
		  background-color: rgba(255, 235, 59, 0.4);
	  }
	  
	  .highlight-green {
		  background-color: rgba(76, 175, 80, 0.25);
	  }
	  
	  .highlight-blue {
		  background-color: rgba(33, 150, 243, 0.25);
	  }
	  
	  .highlight-pink {
		  background-color: rgba(233, 30, 99, 0.25);
	  }

	}
</style>
"""
