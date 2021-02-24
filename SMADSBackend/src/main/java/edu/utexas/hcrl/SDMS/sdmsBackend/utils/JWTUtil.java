package edu.utexas.hcrl.SDMS.sdmsBackend.utils;

import edu.utexas.hcrl.SDMS.sdmsBackend.exceptions.UserNotFoundException;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Service;

import javax.servlet.http.HttpServletRequest;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.function.Function;

@Service
public class JWTUtil {
    private String secret = "mysuperstrongpasswordthatisnotapassword";
    private static final String AUTHORIZATION_HEADER_NAME = "Authorization";

    public int extractId(String token) {
        String userIdString = extractClaim(token, Claims::getSubject);
        return Integer.parseInt(userIdString);
    }

    public Date extractExpiration(String token) {
        return extractClaim(token, Claims::getExpiration);
    }

    public <T> T extractClaim(String token, Function<Claims, T> claimsResolver) {
        final Claims claims = extractAllClaims(token);
        return claimsResolver.apply(claims);
    }
    private Claims extractAllClaims(String token) {
        return Jwts.parser().setSigningKey(secret).parseClaimsJws(token).getBody();
    }

    public Boolean isTokenExpired(String token) {
        return extractExpiration(token).before(new Date());
    }

    public String generateToken(int userId) {
        return generateToken(String.valueOf(userId));
    }

    public String generateToken(String userId) {
        Map<String, Object> claims = new HashMap<>();
        return createToken(claims, userId);
    }

    private String createToken(Map<String, Object> claims, String subject) {
        return Jwts.builder().setClaims(claims).setSubject(subject).setIssuedAt(new Date(System.currentTimeMillis()))
                .setExpiration(new Date(System.currentTimeMillis() + 864000000))
                .signWith(SignatureAlgorithm.HS256, secret).compact();
    }

    public Boolean validateToken(String token, UserDetails userDetails) {
        final int username = extractId(token);
        int userId = -1;
        try {
            userId = Integer.parseInt(userDetails.getUsername());
        } catch (NumberFormatException e) {
            e.printStackTrace();
        }
        return (username == userId && !isTokenExpired(token));
    }

    public int getUserIDFromToken(HttpServletRequest request) throws UserNotFoundException {
        String authorizationHeader = request.getHeader(AUTHORIZATION_HEADER_NAME);
        if (authorizationHeader != null && authorizationHeader.startsWith("Bearer ")) {
            String token = authorizationHeader.substring(7);
            return extractId(token);
        } else {
            throw new UserNotFoundException("User not found in request");
        }
    }
}
