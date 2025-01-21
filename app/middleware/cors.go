package middleware

import (
	"strings"

	"github.com/gin-gonic/gin"
	"github.com/soxft/time-counter/config"
	"github.com/soxft/time-counter/utils/toolutil"
)

func Cors() gin.HandlerFunc {
	return func(c *gin.Context) {
		// 获取请求的 Origin 头
		origin := c.Request.Header.Get("Origin")
		
		// 设置允许跨域的域名列表
		allowedOrigins := config.Server.Cors

		// 检查请求的 Origin 是否在允许的列表中
		var allowOrigin bool
		for _, allowedOrigin := range allowedOrigins {
			if origin == allowedOrigin {
				allowOrigin = true
				break
			}
		}

		// 如果 Origin 在允许的列表中，则允许跨域
		if allowOrigin {
			c.Writer.Header().Set("Access-Control-Allow-Origin", origin)
		} else {
			// 如果没有匹配的 Origin，可以选择设置默认的允许跨域域名
			c.Writer.Header().Set("Access-Control-Allow-Origin", "")
		}

		// 设置其他响应头
		c.Writer.Header().Set("Server", config.Server.Server)

		if c.Request.Method == "OPTIONS" {
			c.Writer.Header().Set("Access-Control-Allow-Methods", "OPTION, HEAD, "+c.Request.Header.Get("Access-Control-Request-Method"))
			c.Writer.Header().Set("Access-Control-Allow-Headers", c.Request.Header.Get("Access-Control-Request-Headers"))
			c.Writer.Header().Set("Access-Control-Max-Age", "86400")
			c.AbortWithStatus(204)
			return
		}

		// token 处理
		token := c.Request.Header.Get("Authorization")
		if token == "" {
			token = toolutil.Md5(c.ClientIP()) + "." + toolutil.Md5(c.Request.UserAgent())
			c.Writer.Header().Set("Access-Control-Expose-Headers", "uuid")
			c.Writer.Header().Set("uuid", token)
		} else {
			token = strings.Replace(token, "Bearer ", "", -1)
		}
		c.Set("user_identity", toolutil.Md5(token))
	}
}