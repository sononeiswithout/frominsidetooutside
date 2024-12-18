use anchor_lang::prelude::*;
use anchor_spl::token::{self, Token, TokenAccount, Transfer};

declare_id!("YourProgramIDHere");

#[program]
pub mod knowledge_nft_directory {
    use super::*;

    pub fn mint_nft(ctx: Context<MintNFT>, uri: String) -> Result<()> {
        let contribution = &mut ctx.accounts.contribution;
        contribution.uri = uri;
        contribution.creator = *ctx.accounts.user.key;
        Ok(())
    }

    pub fn rate_contribution(ctx: Context<RateContribution>, rating: u8) -> Result<()> {
        require!(rating > 0 && rating <= 5, CustomError::InvalidRating);
        let contribution = &mut ctx.accounts.contribution;
        contribution.rating += rating as u64;
        Ok(())
    }
}

#[derive(Accounts)]
pub struct MintNFT<'info> {
    #[account(init, payer = user, space = 8 + 64 + 32)]
    pub contribution: Account<'info, Contribution>,
    #[account(mut)]
    pub user: Signer<'info>,
    pub system_program: Program<'info, System>,
}

#[derive(Accounts)]
pub struct RateContribution<'info> {
    #[account(mut)]
    pub contribution: Account<'info, Contribution>,
    #[account(mut)]
    pub user: Signer<'info>,
    pub token_program: Program<'info, Token>,
}

#[account]
pub struct Contribution {
    pub uri: String,
    pub creator: Pubkey,
    pub rating: u64,
}

#[error_code]
pub enum CustomError {
    #[msg("Invalid rating.")]
    InvalidRating,
}